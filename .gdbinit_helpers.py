import argparse
import functools
import logging
import string
import os
import re
import struct



log = logging.getLogger(__file__)
if not log.hasHandlers():
    handler = logging.StreamHandler()
    formatter = logging.Formatter("%(levelname)s %(message)s")
    log.addHandler(handler)
log.setLevel(logging.DEBUG)


def batch(it, sz):
    for i in range(0, len(it), sz):
        yield it[i:i+sz]


def hexdump_str(bytevals, offset=0, bytes_per_line=16, bytegroupsize=2):
    # get max address size
    max_address = len(bytevals) + offset
    curr_addr = max_address
    address_chr_count = 0
    while curr_addr > 0:
        curr_addr = curr_addr >> 4
        address_chr_count += 1

    if address_chr_count < 8:
        address_chr_count = 8

    hex_byte_print_size = bytes_per_line + ((bytes_per_line // bytegroupsize)-1)
    # generate a line formatstring specifying max widths
    line_fmtstr = '%%0%dx: %%-%ds  %%s' % (address_chr_count,
                                           hex_byte_print_size)
    printable_char_ints = set(string.printable[:-5].encode())

    outlines = []
    for line_num, byteline in enumerate(batch(bytevals, bytes_per_line)):
        line_bytegroups = []
        line_strchrs = ""
        addr = (line_num*bytes_per_line) + offset
        for bytegroup in batch(byteline, bytegroupsize):
            bytegroup_str = ''.join(['%02x' % i for i in bytegroup])
            line_bytegroups.append(bytegroup.hex())
            for b in bytegroup:
                # force the value to stay as a byte instead of converting
                # to an integer
                if b in printable_char_ints:
                    line_strchrs += chr(b)
                else:
                    line_strchrs += '.'
        hex_bytes = ' '.join(line_bytegroups)
        hex_bytes = hex_bytes.ljust(hex_byte_print_size, ' ')
        out_line = line_fmtstr % (addr, hex_bytes, line_strchrs)
        outlines.append(out_line)

    return '\n'.join(outlines)


def execute_output(command):

    basepath = os.getenv('HOME')
    if basepath is None:
        basepath = "/tmp"
    # create temporary file for the output
    filename = os.path.join(basepath, 'gdb_output')

    # set gdb logging
    logging_off_str = "set logging enabled off"

    gdb.execute("set logging file " + filename)
    gdb.execute("set logging overwrite on")
    gdb.execute("set logging redirect on")
    try:
        gdb.execute("set logging enabled on")
    except:
        gdb.execute("set logging on")
        logging_off_str = "set logging off"

    # execute command
    try:
        gdb.execute(command)
    except:
        pass

    # restore normal gdb behaviour
    gdb.execute(logging_off_str)
    gdb.execute("set logging redirect off")

    # read output and close temporary file
    with open(filename, 'r') as f:
        output = f.read()

    # delete file
    os.remove(filename)

    return output


def parse_proc_maps():
    maps = execute_output("info proc mappings")
    split_maps_lines = maps.splitlines()
    start_addr_lines = [(i, s) for i, s in enumerate(split_maps_lines) if s.find('Start Addr') != -1]
    column_names_line_ind, column_names_line = start_addr_lines[0]
    if len(split_maps_lines) == column_names_line_ind + 1:
        log.debug("no mappings for session")
        return []
    column_names_line = column_names_line.strip()
    log.debug("column names line: '%s'", column_names_line)

    # column names can't really be known ahead of time without a big version table,
    # and even then it isn't very reliable. also because columns can be separated by
    # a single space and column names can also contain a space, splitting column
    # names isn't really reliable either

    col_names = ["Start Addr", "End Addr", "Size", "Offset", "Perms", "objfile"]
    col_names += [
        "\S+\s\S+",  # catchall for unk column names with a single space in them
        "\S+",  # catchall for unk column names without a single space in them
                # but after the space one so that this matches last
    ]

    col_names_pat = "(%s)" % "|".join(col_names)
    log.debug("col_names_pat: '%s'", col_names_pat)
    col_names_rexp = re.compile(col_names_pat, re.I)
    ordered_column_names = [m.groups()[0] for m in re.finditer(col_names_rexp, column_names_line)]

    colname_to_pattern_map = {
        "objfile": "(?:.+)?"
    }
    # order of columns is now known
    line_sub_patterns = []
    for col_name in ordered_column_names:
        sub_pat = colname_to_pattern_map.get(col_name, "\S+")
        sanitized_col_name = re.sub("\s", "_", col_name)
        sub_pat_with_name = "(?P<%s>%s)" % (sanitized_col_name, sub_pat)
        log.debug("adding '%s'", sub_pat_with_name)
        line_sub_patterns.append(sub_pat_with_name)

    line_pattern = "\s+".join(line_sub_patterns)
    log.debug("line_pattern: '%s'", line_pattern)
    line_rexp = re.compile(line_pattern)
    search_lines = split_maps_lines[column_names_line_ind+1:]
    maybe_matches = [re.search(line_rexp, i) for i in search_lines]
    matches = [i for i in maybe_matches if i is not None]
    if len(matches) != len(maybe_matches):
        none_inds = [i for i, s in enumerate(maybe_matches) if s is None]
        for ind in none_inds:
            log.warning("match failed on '%s'", search_lines[ind])
    return [i.groupdict() for i in matches]


def get_file_paths(directory):
    for dirpath, dirnames, filenames in os.walk(directory):
        for filename in filenames:
            yield os.path.join(dirpath, filename)


def add_symbol_files_for_core(searchdir=None):

    proc_maps_entries = parse_proc_maps()
    useful_entries = []
    for e in proc_maps_entries:
        if e['objfile'] == '':
            continue
        if e['Offset'] != "0x0":
            continue
        if e['objfile'].startswith("/dev"):
            continue
        useful_entries.append(e)

    useful_entries_by_basename = {os.path.basename(e['objfile']): e for e in useful_entries}

    if searchdir is None:
        searchdir = os.getcwd()

    add_symbol_commands = []
    for path in get_file_paths(searchdir):
        basename = os.path.basename(path)
        entry = useful_entries_by_basename.get(basename)
        if entry is None:
            continue

        add_sym_command = "add-symbol-file -readnow -o %s %s" % (entry['Start_Addr'], path)
        add_symbol_commands.append(add_sym_command)

    for cmd in add_symbol_commands:
        gdb.execute(cmd)


def identify_anonymous_regions_in_core():
    maps_entries = parse_proc_maps()
    maps_entries_start_addr_pat = "(%s)->" % "|".join([e['Start_Addr'] for e in maps_entries])
    maint_sect = execute_output("maintenance info sections")
    maint_sect_lines = maint_sect.splitlines()

    loaded_or_allocd_lines = [i for i in maint_sect_lines if re.search("(ALLOC|LOAD)", i) is not None]
    anonymous_entry_lines = [i for i in loaded_or_allocd_lines if re.search(maps_entries_start_addr_pat, i) is None]
    anonymous_entries = []
    for line in anonymous_entry_lines:
        m = re.search("(?P<Start_Addr>0x[a-f0-9]+)->(?P<End_Addr>0x[a-f0-9]+)", line, re.I)
        if m is None:
            continue
        gd = m.groupdict()
        gd['Size'] = "%#x" % (int(gd['End_Addr'], 16) - int(gd['Start_Addr'], 16))
        gd['Offset'] = '0x0'
        gd['objfile'] = ''
        anonymous_entries.append(gd)
    return anonymous_entries


class FuncArgsBreakPoint(gdb.Command):
    USAGE = "Usage: funcargsbp <breakpoint_name> <breakpoint addr> [[fmt-string]...[args]]"

    def __init__(self):
        super(FuncArgsBreakPoint, self).__init__("funcargsbp", gdb.COMMAND_USER, gdb.COMPLETE_COMMAND)

    def invoke(self, argstr, from_tty):
        try:
            args = argstr.split(maxsplit=2)
        except ValueError:
            raise Exception(self.USAGE)
        if len(args) < 2:
            raise Exception(self.USAGE)
        # print(args)
        bp_name, bp_addr_str = args[:2]
        bp_print_args_fmt = "\"%s\\n\"" % bp_name
        bp_print_args_spec = args[:2]
        # bp_print_args_spec[0] = '"%s"' % bp_print_args_spec[0]
        if len(args) >= 3:
            bp_print_args_fmt = ", ".join(args[2:])
            bp_print_args_fmt = bp_print_args_fmt.replace("${BPNAME}", bp_name)

        command = ""
        command += "set $BP_%s = %s\n" % (bp_name, bp_addr_str)
        command += "b *$BP_%s\n" % bp_name
        command += "set $BP_%s_bpnum = $bpnum\n" % bp_name
        command += "commands\n"
        command += "    silent\n"
        command += "    printf %s\n" % bp_print_args_fmt
        command += "    continue\n"
        command += "end\n"
        # print(command)
        gdb.execute(command, from_tty=False)

FuncArgsBreakPoint()


class SaveValBP(gdb.Command):

    def __init__(self):
        super(SaveValBP, self).__init__("savevalbp", gdb.COMMAND_USER, gdb.COMPLETE_COMMAND)
        self.parser = argparse.ArgumentParser()
        self.parser.add_argument("addr", help="address to break and store values")
        self.parser.add_argument("displaytype", help="How to display the saved value")
        self.parser.add_argument("register", help="register to store the value of")

    def invoke(self, argstr, from_tty):
        # don't auto repeat
        self.dont_repeat()
        args = self.parser.parse_args(argstr)

SaveValBP()


def parse_gdb_cmd_args(argstr):
    # log.debug("argstr '%s'", argstr)
    gdb_evaluated_args = []
    for arg in gdb.string_to_argv(argstr):
        try:
            # try to evaluate each arg in case it is an expression first
            evaluated_arg = gdb.parse_and_eval(arg)
            string_arg = evaluated_arg.format_string()
        except gdb.error:
            # if evaluation fails just use the raw arg
            string_arg = arg
        gdb_evaluated_args.append(string_arg)
    # log.debug("gdb_evaluated_args %s", str(gdb_evaluated_args))
    return gdb_evaluated_args


class PrintBufferInHex(gdb.Command):
    def __init__(self):
        super(PrintBufferInHex, self).__init__("printbufinhex", gdb.COMMAND_USER, gdb.COMPLETE_COMMAND)
        self.parser = argparse.ArgumentParser()
        self.parser.add_argument("addr", help="address to print buffer at", type=functools.partial(int, base=0))
        self.parser.add_argument("size", help="size of buffer", type=functools.partial(int, base=0))

    def invoke(self, argstr, from_tty):
        raw_args = parse_gdb_cmd_args(argstr)
        args = self.parser.parse_args(raw_args)
        # log.debug("address %s" % hex(args.addr))
        # log.debug("buf size %s" % hex(args.size))
        cur_infer = gdb.selected_inferior()
        mem = cur_infer.read_memory(args.addr, args.size)
        mem_bytes = mem.tobytes()
        print(mem_bytes.hex(), end='')


PrintBufferInHex()


class HexdumpBuf(gdb.Command):
    def __init__(self):
        super(HexdumpBuf, self).__init__("hexdumpbuf", gdb.COMMAND_USER, gdb.COMPLETE_COMMAND)
        self.parser = argparse.ArgumentParser()
        self.parser.add_argument("addr", help="address to hexdump", type=functools.partial(int, base=0))
        self.parser.add_argument("size", help="size of buffer", type=functools.partial(int, base=0))

    def invoke(self, argstr, from_tty):
        raw_args = parse_gdb_cmd_args(argstr)
        args = self.parser.parse_args(raw_args)
        # log.debug("address %s" % hex(args.addr))
        # log.debug("buf size %s" % hex(args.size))
        cur_infer = gdb.selected_inferior()
        mem = cur_infer.read_memory(args.addr, args.size)
        mem_bytes = mem.tobytes()
        print(hexdump_str(mem_bytes, offset=args.addr))


HexdumpBuf()


class GDBPointerUtils:
    def __init__(self, endian="little", pointersize=4):
        self.ptr_size = pointersize
        self.page_size = 0x1000
        self.ptr_pack_sym = ""
        self.max_addr = 0
        if self.ptr_size == 4:
            self.max_addr = 0x80000000
            self.ptr_pack_sym = "I"
        elif self.ptr_size == 8:
            self.max_addr = 0x8000000000000000
            self.ptr_pack_sym = "Q"

        self.endian = ""
        self.pack_endian = ""
        if endain.lower() in ["big", "be", "msb"]:
            self.pack_endian = ">"
            self.endian = "big"
        elif endian.lower() in ["little", "le", "lsb"]:
            self.pack_endian = "<"
            self.endian = "little"
        else:
            raise Exception("unknown endian")
        self.ptr_pack_code = self.pack_endian + self.ptr_pack_sym

    def gen_char_class_range(self, lower_bound, upper_bound):

        # can't be used to specify a range in a regex pattern either
        # now or in the near future
        invalid_range_spec = [ord(b'-'), ord(b'\\'), ord(b']')]

        # code for finding new invalid range specifiers as python adds them
        # invalid_range_spec = []
        # for i in range(1, 256):
        #     byt = bytearray([i])
        #     try:
        #         rexp = re.compile(b'([\x00-%s])' % byt)
        #         if re.search(rexp, byt) is None:
        #             raise Exception("invalid")
        #     except:
        #         invalid_range_spec.append(byt)
        # print(invalid_range_spec)

        end_bytes = []
        ranges = []
        # sanitize the range specifiers to remove invalid chars
        if lower_bound in invalid_range_spec:
            end_bytes.append(bytearray([lower_bound]))
            lower_bound += 1

        if upper_bound in invalid_range_spec:
            end_bytes.append(bytearray([upper_bound]))
            upper_bound -= 1

        # pattern will end up like b'[\xfd-\x00]', split into two
        # different ranges instead
        if lower_bound > upper_bound:
            new_upper_ranges, new_upper_end_bytes = self.gen_char_class_range(0, upper_bound)
            ranges.extend(new_upper_ranges)
            end_bytes.extend(new_upper_end_bytes)
            # adding this here might not be necessary, but since it is already
            # sanitized it shouldn't hurt
            end_bytes.append(bytearray([upper_bound]))
            upper_bound = 0xff

        # if the two are the same there is no need to make an additional range,
        if lower_bound == upper_bound:
            end_bytes.append(bytearray([lower_bound]))
            return ranges, end_bytes

        # don't actually add end bytes until the end, because some special
        # characters MUST be at the end, and this could just be a
        # recursive call
        new_range = b"%s-%s" % (bytearray([lower_bound]),
                                bytearray([upper_bound]))
        ranges.append(new_range)
        return ranges, end_bytes

    def generate_address_range_pattern(self, minimum_addr, maximum_addr):
        """
        Generate a regular expression pattern that can be used to match
        the bytes for an address between minimum_addr and maximum_addr
        (inclusive). This works best for small ranges, and will break
        somewhat if there are non-contiguous memory blocks, but it works
        well enough for most things
        """
        diff = maximum_addr - minimum_addr
        val = diff
        # calculate the changed number of bytes between the minimum_addr and the maximum_addr
        byte_count = 0
        while val > 0:
            val = val >> 8
            byte_count += 1

        # generate a sufficient wildcard character classes for all of the bytes that could fully change
        wildcard_bytes = byte_count - 1
        wildcard_pattern = b"[\x00-\xff]"
        boundary_byte_upper = (maximum_addr >> (wildcard_bytes*8)) & 0xff
        boundary_byte_lower = (minimum_addr >> (wildcard_bytes*8)) & 0xff
        # arbitrarily escaping ascii bytes is not valid in newer versions of python
        # boundary_byte_pattern = b"[\\%s-\\%s]" % (bytearray([boundary_byte_lower]),
        #                                           bytearray([boundary_byte_upper]))
        ranges, end_bytes = self.gen_char_class_range(boundary_byte_lower,
                                                      boundary_byte_upper)
        # TODO: actually dedup end bytes
        # move the b'-' to the end if present
        end_bytes.sort(key=lambda a: a == b'-')
        # escape end bytes properly
        escaped_end_bytes = b''.join([bytearray([ord(b'\\')]) + i for i in end_bytes])
        ranges_str = b''.join(ranges)
        # create a character class that will match the largest changing byte
        boundary_byte_pattern = b'[%s%s]' % (range_str, escaped_end_bytes)

        address_pattern = b''
        single_address_pattern = b''
        if self.endian != "big":
            packed_addr = struct.pack(self.ptr_pack_sym, minimum_addr)
            single_address_pattern = b''.join([wildcard_pattern*wildcard_bytes,
                                               boundary_byte_pattern,
                                               packed_addr[byte_count:]])
        else:
            packed_addr = struct.pack(self.ptr_pack_sym, minimum_addr)
            single_address_pattern = b''.join([packed_addr[:byte_count],
                                               boundary_byte_pattern,
                                               wildcard_pattern*wildcard_bytes])

        # empty_addr = struct.pack(self.ptr_pack_sym, 0)

        address_pattern = b"(%s)" % single_address_pattern
        return address_pattern

    def generate_address_range_rexp(self, minimum_addr, maximum_addr):
        """
        Generate a regular expression that can match on any value between
        the provided minimum addr and maximum addr
        """
        address_pattern = self.generate_address_range_pattern(minimum_addr, maximum_addr)
        address_rexp = re.compile(address_pattern, re.DOTALL | re.MULTILINE)
        return address_rexp

    def ptr_ints_from_bytearray(self, bytarr):
        """
        Returns a tuple of poitner-sized ints unpacked from the provided
        bytearray
        """
        bytarr = bytearray(bytarr)
        # truncate in case the bytarray isn't aligned to ptr size
        fit_len = len(bytarr) // self.ptr_size
        pack_code = "%s%d%s" % (self.pack_endian, fit_len, self.ptr_pack_sym)
        return struct.unpack_from(pack_code, bytarr)

    def search_for_pointer(self, pointer):
        """
        Find all locations where a specific pointer is embedded in memory
        """

        pointer_bytes = struct.pack(self.ptr_pack_code, pointer)
        pointer_pattern = re.escape(pointer_bytes)
        address_rexp = re.compile(pointer_pattern, re.DOTALL | re.MULTILINE)
        match_addrs, _ = self.search_memory_for_rexp(address_rexp)
        return match_addrs

    def search_memory_for_rexp(self, rexp, save_match_objects=True):
        """
        Given a regular expression, search through all of the program's
        memory blocks for it and return a list of addresses where it was found,
        as well as a list of the match objects. Set `save_match_objects` to
        False if you are searching for exceptionally large objects and
        don't want to keep the matches around
        """
        inf = gdb.selected_inferior()

        all_match_addrs = []
        all_match_objects = []
        for region_start in range(0, self.max_addr, self.page_size):
            try:
                search_bytes = inf.read_memory(region_start, self.page_size)
            except:
                continue
            iter_gen = re.finditer(rexp, search_bytes)
            match_count = 0
            # hacky loop over matches so that the recursion limit can be caught
            while True:
                try:
                    m = next(iter_gen)
                except StopIteration:
                    # this is where the loop is normally supposed to end
                    break
                except RuntimeError:
                    # this means that recursion went too deep
                    print("match hit recursion limit on match %d" % match_count)
                    break
                match_count += 1
                location_addr = region_start + m.start()
                all_match_addrs.append(location_addr)
                if save_match_objects:
                    all_match_objects.append(m)
        return all_match_addrs, all_match_objects


class MemoryRegion:
    def __init__(self):
        self.start_addr = 0
        self.end_addr = 0
        self.size = 0
        self.offset = 0
        self.perms = ""
        self.objfile = ""

    @staticmethod
    def from_dict(in_dict):
        reg = MemoryRegion()

        hexinttype = functools.partial(int, base=16)
        dict_to_field_mappings = {
            "Start_Addr": ("start_addr", hexinttype),
            "End_Addr": ("end_addr", hexinttype),
            "Size": ("size", hexinttype),
            "Offset": ("offset", hexinttype),
            "Perms": ("perms", str),
            "objfile": ("objfile", str),
        }
        for k in in_dict.keys():
            field_name, field_type = dict_to_field_mappings.get(k, (k, str))
            setattr(reg, field_name, field_type(in_dict[k]))
        return reg

    def contains(self, address):
        return address >= self.start_addr and address <= self.end_addr

    def __repr__(self):
        return "%#x %#x %#x %s" % (self.start_addr, self.end_addr,
                                   self.size, self.objfile)
