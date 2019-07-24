import shutil
import os
import configparser
import argparse
import re

global verbose


def verbose_print(*args, **kwargs):
    if verbose is True:
        print(*args, **kwargs)


def sanitize(commit):
    """This should be replaced with something better"""
    commit = re.sub(r"(`|\"|;|\$|<|>|&|\||#|\*|!!)", "", commit)
    return commit


def get_file_offsets(path, specified_file_names=None):
    """return all of the files in the specified path, or if filenames are specified
    :param path:
    :param specified_file_names:
    :return:
    """
    file_paths = list()

    for root, dirs, files in os.walk(path):
        root_offset = root.replace(path, "")
        if len(root_offset) > 0 and root_offset[0] == "/":
            root_offset = root_offset[1:]
        if specified_file_names is not None:
            paths_to_return = [os.path.join(root_offset, i) for i in files if i in specified_file_names]
        else:
            paths_to_return = [os.path.join(root_offset, i) for i in files]
        file_paths.extend(paths_to_return)
    return file_paths


def install_dotfiles(specified_files=None):
    dotfiles_repo_dir = os.path.abspath(os.path.dirname(__file__))
    offsets = get_file_offsets(dotfiles_repo_dir, specified_files)
    home = os.path.expanduser("~")
    ignore_patterns = [r'\.idea', r'\.git/', r'my-dotfiles-settings', r'\.gitignore']
    for pat in ignore_patterns:
        offsets = [s for s, i in [(m, re.search(pat, m)) for m in offsets] if i is None]

    for offset in offsets:
        verbose_print(f"home: {home}")
        verbose_print(f"offset: {offset}")
        dest = os.path.join(home, offset)
        verbose_print(f"dest: {dest}")
        dest_dir = os.path.dirname(dest)
        verbose_print(f"dest_dir: {dest_dir}")
        if not os.path.exists(dest_dir):
            verbose_print(f"Making makedirs: {dest_dir}")
            os.makedirs(dest_dir, exist_ok=True)
        shutil.copy(os.path.join(dotfiles_repo_dir, offset), dest)
        verbose_print("source: " + os.path.join(dotfiles_repo_dir, offset))


parser = argparse.ArgumentParser(description="This is a quick script to update dotfiles quickly. Settings are "
                                             "located in ~/.config/my-dotfiles-settings")
parser.add_argument("--list-files", help="Lists files that will be updated", action="store_true", default=False)
parser.add_argument("--list-repos", help="List the repo locations that will be updated",
                    action="store_true", default=False)
parser.add_argument("--install", help="Install files to current user's config", default=False, action="store_true")
parser.add_argument("--files", help="Specific files that you would like to update", nargs="+")
parser.add_argument("--commit", help="Commit message for git repo",
                    type=str, default="")
parser.add_argument("--verbose", help="verbose mode", action="store_true", default=False)
args = parser.parse_args()

verbose = args.verbose

if args.install is True and args.files is None:
    install_dotfiles(args.files)
    print("Dotfiles installed")
    exit(0)

config_file_path = os.path.expanduser("~/.config/my-dotfiles-settings")
# check for config file 
if not os.path.exists(config_file_path):
    print('file ~/.config/my-dotfiles-settings does not exist. exiting')
    exit(1)

config_parser = configparser.ConfigParser(allow_no_value=True)

config_parser.optionxform = str
config_args = config_parser.read(config_file_path)
# do section validation here
home = os.path.expanduser("~")
if args.files is None or args.list_files is True:
    files_to_update = list(config_parser["files-to-update"].keys())
else:
    files_to_update = [i.replace(home + "/", "") for i in args.files]
repo_locations = [os.path.expanduser(i) for i in list(config_parser["repo-location"].keys())]

if args.install is True and args.files is not None:
    install_dotfiles(args.files)
    exit(0)

if args.list_files is True:
    for i in files_to_update:
        print(i)
    exit(0)

if args.commit != "":
    args.commit = sanitize(args.commit)

if args.list_repos is True:
    if len(repo_locations) < 1:
        print("No repo locations listed. Add repo locations to ~/.config/my-dotfiles-settings. exiting")
        exit(1)
    for i in repo_locations:
        print(i)
    exit(0)


original_dir = os.getcwd()
for repo in repo_locations:
    if not os.path.exists(repo):
        print(f"Repo {repo} does not exist")
        continue

    for file in files_to_update:
        file_path = os.path.join(os.path.expanduser("~"), file)
        if not file_path:
            print(f"file {file_path} does not exist and will not be copied to the repo")
            continue

        repo_dir_path = os.path.split(os.path.join(repo, file))[0]
        if not os.path.exists(repo_dir_path):
            os.makedirs(repo_dir_path, exist_ok=True)
        if not os.path.exists(file_path):
            verbose_print(f"File: {file_path} does not exist, skipping")
            continue
        shutil.copy(file_path, os.path.join(repo, file))
        if args.commit != "":
            os.chdir(repo_dir_path)
            os.system("git add -A")

    if args.commit != "":
        print("Pushing to git")
        os.chdir(repo)
        os.system(f"git commit -m \"{args.commit}\"")
        os.system("git push")

os.chdir(original_dir)
print("done")

