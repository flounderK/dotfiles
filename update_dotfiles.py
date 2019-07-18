import shutil
import os
import configparser
import argparse
import re


def sanitize(commit):
    """This should be replaced with something better"""
    commit = re.sub(r"(`|\"|;|\$|<|>|&|\||#|\*|!!)", "", commit)
    return commit


def copytree(src, dst, symlinks=False, ignore=None):
    for item in os.listdir(src):
        source = os.path.join(src, item)
        dest = os.path.join(dst, item)
        if os.path.isdir(source):
            shutil.copytree(source, dest, symlinks, ignore)
        else:
            shutil.copy(source, dest)


def install_dotfiles():
    dotfiles_repo_dir = os.path.split(__file__)[0]
    home = os.path.expanduser("~")
    trees = os.listdir(dotfiles_repo_dir)
    ignore_pattern = shutil.ignore_patterns(".idea*", ".git*", "my-dotfiles-settings")
    for tree in trees:
        copytree(os.path.join(dotfiles_repo_dir, tree), os.path.join(home, tree), ignore=ignore_pattern)


parser = argparse.ArgumentParser(description="This is a quick script to update dotfiles quickly. Settings are "
                                             "located in ~/.config/my-dotfiles-settings")
parser.add_argument("--list-files", help="Lists files that will be updated", action="store_true", default=False)
parser.add_argument("--list-repos", help="List the repo locations that will be updated",
                    action="store_true", default=False)
parser.add_argument("--install", help="Install files to current user's config", default=False, action="store_true")
parser.add_argument("--files", help="Specific files that you would like to update", nargs="+")
parser.add_argument("--commit", help="Commit message for git repo",
                    type=str)
args = parser.parse_args()

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
for i in repo_locations:
    print(i)
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

if args.install is True:
    install_dotfiles()
    print("Dotfiles installed")
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

