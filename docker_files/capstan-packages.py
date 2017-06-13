#!/usr/bin/env python

import subprocess
import os
import shutil
import tempfile
import re
import glob
from timeit import default_timer

OSV_DIR = '/git-repos/osv'
RECIPES_DIR = '/recipes'
RESULTS_DIR = '/result'
SHARE_OSV_DIR = False
LOG_DIR = os.path.join(RESULTS_DIR, 'log')

# final osv-loader location e.g. /results/osv-loader.qemu
result_osv_loader_file = os.path.join(RESULTS_DIR, 'osv-loader.qemu')
# final osv-loader index location e.g. /results/index.yaml
result_osv_loader_index_file = os.path.join(RESULTS_DIR, 'index.yaml')


class Timer:
    def __init__(self):
        self.global_t = default_timer()
        self.t = default_timer()

    def start(self):
        self.t = default_timer()

    def report(self, msg):
        print('Time elapsed for %s: %.2f seconds' % (msg, default_timer() - self.t))

    def report_global(self):
        print('\n\nTotal time elapsed: %.2f seconds' % (default_timer() - self.global_t))


TIMER = Timer()


class Colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def _print_ok(txt):
    print(Colors.OKGREEN + Colors.BOLD + txt + Colors.ENDC)


def _print_err(txt):
    print(Colors.FAIL + Colors.BOLD + txt + Colors.ENDC)


def _print_warn(txt):
    print(Colors.WARNING + 'WARN: ' + txt + Colors.ENDC)


class Recipe:
    def __init__(self, root, name):
        # package name e.g. eu.mikelangelo-project.osv.bootstrap
        self.name = name
        # where recipe is e.g. /recipes/eu.mikelangelo-project.osv.bootstrap
        self.dir = os.path.join(root, name)

        # where recipe demo is e.g. /recipes/eu.mikelangelo-project.osv.bootstrap/demo
        self.demo_dir = os.path.join(self.dir, 'demo')
        # where recipe demo package is e.g. /recipes/eu.mikelangelo-project.osv.bootstrap/demo/package
        self.demo_pkg_dir = os.path.join(self.demo_dir, 'pkg')
        # where recipe demo expected stdout is e.g. /recipes/eu.mikelangelo-project.osv.bootstrap/demo/expected-stdout.txt
        self.demo_expect = os.path.join(self.demo_dir, 'expected-stdout.txt')
        # where recipe demo package.yaml template is e.g. /recipes/eu.mikelangelo-project.osv.bootstrap/demo/package/meta/package.yaml.templ
        self.demo_yaml_templ = os.path.join(self.demo_pkg_dir, 'meta', 'package.yaml.templ')
        # where recipe demo package.yaml is e.g. /recipes/eu.mikelangelo-project.osv.bootstrap/demo/package/meta/package.yaml
        self.demo_yaml = os.path.join(self.demo_pkg_dir, 'meta', 'package.yaml')
        # where recipe demo run.yaml is e.g. /recipes/eu.mikelangelo-project.osv.bootstrap/demo/package/meta/run.yaml
        self.demo_run_yaml = os.path.join(self.demo_pkg_dir, 'meta', 'run.yaml')

        # where recipe results are e.g. /results/eu.mikelangelo-project.osv.bootstrap
        self.result_dir = os.path.join(RESULTS_DIR, self.name)
        # final .mpm location e.g. /results/eu.mikelangelo-project.osv.bootstrap.mpm
        self.result_mpm_file = os.path.join(RESULTS_DIR, '%s.mpm' % self.name)
        # final .yaml location e.g. /results/eu.mikelangelo-project.osv.bootstrap.yaml
        self.result_yaml_file = os.path.join(RESULTS_DIR, '%s.yaml' % self.name)
        # intermediate .mpm location e.g. /results/eu.mikelangelo-project.osv.bootstrap/eu.mikelangelo-project.osv.bootstrap.mpm
        self.result_orig_mpm_file = os.path.join(self.result_dir, '%s.mpm' % self.name)
        # intermediate .yaml location e.g. /results/eu.mikelangelo-project.osv.bootstrap/meta/package.yaml
        self.result_orig_yaml_file = os.path.join(self.result_dir, 'meta', 'package.yaml')

        # where osv source code is e.g. /git-repos/osv
        self.osv_dir = OSV_DIR

        # should be this recipe built using clone of osv dir (set to False for debugging to speed things up)
        self.do_isolate_osv_dir = not SHARE_OSV_DIR
        # does this recipe contain demo package
        self.has_demo_package = os.path.isfile(self.demo_run_yaml)
        # where does this recipe write stdout/stderr of build.sh to
        self.log_name = '%s.log' % self.name
        self.log_file = os.path.join(LOG_DIR, self.log_name)


def prepare_osv_scripts():
    """
    prepare_osv_scripts() prepares whatever is needed when container is first run after being built. Namely,
    it applies patches to selected OSv scripts.      
    """
    _print_ok('Preparing OSv scripts')

    with open('/common/skip_vm_uploads.patch', 'r') as f:
        c = 'patch -p1'
        p = subprocess.Popen(
            c.split(),
            cwd=OSV_DIR,
            stdin=f,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        output, error = p.communicate()

        if p.returncode != 0:
            _print_err('Applying patch /common/skip_vm_uploads.patch returned non-zero status code')
            print('--- STDOUT: ---\n%s' % output)
            print('--- STDERR: ---\n%s' % error)

    with open('/common/upload_manifest.py.patch', 'r') as f:
        c = 'patch -p1'
        p = subprocess.Popen(
            c.split(),
            cwd=OSV_DIR,
            stdin=f,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        output, error = p.communicate()

        if p.returncode != 0:
            _print_err('Applying patch /common/upload_manifest.py.patch returned non-zero status code')
            print('--- STDOUT: ---\n%s' % output)
            print('--- STDERR: ---\n%s' % error)

    with open('/common/add_mike_apps_to_config.patch', 'r') as f:
        c = 'patch -p1'
        p = subprocess.Popen(
            c.split(),
            cwd=OSV_DIR,
            stdin=f,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        output, error = p.communicate()

        if p.returncode != 0:
            _print_err('Applying patch /common/add_mike_apps_to_config.patch returned non-zero status code')
            print('--- STDOUT: ---\n%s' % output)
            print('--- STDERR: ---\n%s' % error)


def prepare_log_dir():
    if os.path.isdir(LOG_DIR):
        shutil.rmtree(LOG_DIR)
    os.makedirs(LOG_DIR)
    os.chmod(LOG_DIR, 0777)


def clear_result_dir():
    """
    clear_result_dir() deletes whatever is currently in RESULTS_DIR.
    """
    _print_ok('Clearing result directory %s' % RESULTS_DIR)

    for name in os.listdir(RESULTS_DIR):
        path = os.path.join(RESULTS_DIR, name)
        if os.path.isfile(path):
            os.unlink(path)
        else:
            shutil.rmtree(path)


def clear_result_dir_specific(recipes):
    """
    clear_result_dir_specific() deletes delievered results of selected recipes.
    """
    _print_ok('Clearing specific packages from result directory %s' % RESULTS_DIR)

    for recipe in recipes:
        shutil.rmtree(recipe.result_dir, ignore_errors=True)
        if os.path.isfile(recipe.result_mpm_file):
            os.unlink(recipe.result_mpm_file)
        if os.path.isfile(recipe.result_yaml_file):
            os.unlink(recipe.result_yaml_file)


def provide_loader_image():
    """
    provide_mike_osv_loader() copies loader image from OSv build directory into /result directory.
    """
    _print_ok('Providing loader image into result directory %s' % RESULTS_DIR)

    print('Copy loader.img')
    shutil.copy2(os.path.join(OSV_DIR, 'build', 'last', 'loader.img'), result_osv_loader_file)

    print('Create index.yaml')
    s = '''
        format_version: "1"
        version: "v0.24-116-g73b38d8"
        created: "2016-06-11T15:41:07"
        description: "OSv Bootloader"
        build: "scripts/build"
    '''

    with open(result_osv_loader_index_file, 'w') as f:
        f.write(s)

    print('Set permissions to 0777')
    os.chmod(result_osv_loader_file, 0777)
    os.chmod(result_osv_loader_index_file, 0777)


def available_recipes(root):
    """
    list_recipes() searches for folders in given direcotry and instantiates Recipe object for each. 
    :param root: directory where recipes folders are in
    :return: set of recipe names
    """
    return set([name for name in os.listdir(root) if os.path.isdir(os.path.join(root, name))])


def select_recipes(filter_names):
    """
    select_recipes() provides a list of Recipe instances that are to be built. By default it returns a list of
    all available recipes, but if RECIPES environment variable is set, it applies it as filter.
    :return: list of Recipe instances
    """
    _print_ok('Selecting recipes')

    if filter_names == '[]':
        print('Returning empty recipe list')
        return []

    all_recipe_names = available_recipes(RECIPES_DIR)
    if filter_names:
        print('Filtering recipes based on environment variable')
        filter_names = set([name for name in filter_names.split(',')])

        if not filter_names.issubset(all_recipe_names):
            raise RuntimeError('environment variable RECIPES contains invalid recipes: %s' %
                               list(filter_names.difference(all_recipe_names)))
        return [Recipe(RECIPES_DIR, name) for name in filter_names]
    return [Recipe(RECIPES_DIR, name) for name in all_recipe_names]


def build_recipe(recipe):
    """
    build_recipe() runs recipe's "build.sh" script within the prepared context. Result of build.sh script is
    uncompressed Capstan package folder RESULT_DIR/{recipe.name} that contains at least meta/package.yaml file.
    
    :param recipe: Recipe instance
    :return: True if build was successful, False otherwise
    """
    _print_ok('Building recipe %s' % recipe.name)

    if recipe.do_isolate_osv_dir:
        print('Preparing isolated osv directory')
        osv_dir_clone = os.path.join(tempfile.mkdtemp(), 'osv')
        shutil.copytree(recipe.osv_dir, osv_dir_clone, symlinks=True)
        recipe.osv_dir = osv_dir_clone

    print('Preparing result directory for recipe')
    shutil.rmtree(recipe.result_dir, ignore_errors=True)
    os.makedirs(recipe.result_dir)

    print('Running build.sh script')
    print('(meanwhile you can use `tail -F result/%s` to observe logs)' % recipe.log_name)

    with open(recipe.log_file, 'w') as f:
        p = subprocess.Popen(
            './build.sh',
            cwd=recipe.dir,
            env={
                'RECIPE_DIR': recipe.dir,
                'PACKAGE_RESULT_DIR': recipe.result_dir,
                'PACKAGE_NAME': recipe.name,

                'OSV_DIR': recipe.osv_dir,
                'OSV_BUILD_DIR': os.path.join(recipe.osv_dir, 'build', 'release.x64'),
                'GCCBASE': os.path.join(recipe.osv_dir, 'external', 'x64', 'gcc.bin'),
                'MISCBASE': os.path.join(recipe.osv_dir, 'external', 'x64', 'misc.bin'),
                'PATH': os.environ.get('PATH'),
                'HOME': '/root',
            },
            stdout=f,
            stderr=f,
        )
        p.wait()

    if p.returncode != 0:
        _print_err('build.sh returned non-zero status code for recipe %s:' % recipe.dir)
        print('Please see log files inside %s directory' % LOG_DIR)
        return False

    print('Verifying that result contains meta/package.yaml')
    if not os.path.isfile(recipe.result_orig_yaml_file):
        _print_err('build.sh script did not create meta/package.yaml file')
        return False

    print('Set permissions to 0777')
    os.chmod(recipe.result_dir, 0777)

    if recipe.do_isolate_osv_dir:
        print('Cleanup')
        shutil.rmtree(recipe.osv_dir, ignore_errors=True)

    return True


def provide_mpm_for_recipe(recipe):
    """
    provide_mpm_for_recipe() compresses result of build_recipe() into .mpm file and provides it into /result directory.
    This function should only be called after build_recipe() succeeded.
    :param recipe: Recipe instance
    :return: True on success, False otherwise
    """
    _print_ok('Providing mpm for package "%s" into result directory %s' % (recipe.name, RESULTS_DIR))

    print('capstan package build')
    p = subprocess.Popen(
        'capstan package build'.split(),
        cwd=recipe.result_dir,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    output, error = p.communicate()

    if p.returncode != 0:
        _print_err('"capstan package build" returned non-zero status code for package %s:' % recipe.result_dir)
        print('--- STDOUT: ---\n%s' % output)
        print('--- STDERR: ---\n%s' % error)
        return False

    print('Copy .mpm and .yaml')
    if os.path.exists(recipe.result_mpm_file):
        os.remove(recipe.result_mpm_file)
    shutil.move(recipe.result_orig_mpm_file, recipe.result_mpm_file)
    shutil.copy2(recipe.result_orig_yaml_file, recipe.result_yaml_file)

    print('Set permissions to 0777')
    os.chmod(recipe.result_mpm_file, 0777)
    os.chmod(recipe.result_yaml_file, 0777)

    return True


def build_and_provide_recipe_list(recipes):
    """
    build_and_provide_recipe_list() first builds all recipes and then compresses them into mpm packages that
    are located in RESULTS_DIR.
    :param recipes: list of Recipe instances
    """
    for recipe in recipes:
        TIMER.start()
        if build_recipe(recipe):
            provide_mpm_for_recipe(recipe)
        TIMER.report('build recipe')


def prepare_test_capstan_root():
    """
    prepare_test_capstan_root() creates a fresh temporary CAPSTAN_ROOT with all the newly compiled packages in it.
    :return: path to CAPSTAN_ROOT
    """
    print('Generating fresh CAPSTAN_ROOT')
    capstan_root = tempfile.mkdtemp()
    print('CAPSTAN_ROOT=%s' % capstan_root)

    print('Copying all mpms and yamls into CAPSTAN_ROOT')
    repo_packages_dir = os.path.join(capstan_root, 'packages')
    os.mkdir(repo_packages_dir)
    mpms = list(glob.iglob(os.path.join(RESULTS_DIR, "*.mpm")))
    yamls = list(glob.iglob(os.path.join(RESULTS_DIR, "*.yaml")))
    for file in mpms + yamls:
        shutil.copy2(file, repo_packages_dir)
    print('Number of mpms copied: %d' % len(mpms))

    print('Copying mike/osv-loader into CAPSTAN_ROOT')
    repo_osv_loader_dir = os.path.join(capstan_root, 'repository', 'mike', 'osv-loader')
    os.makedirs(repo_osv_loader_dir)
    shutil.copy2(result_osv_loader_file, repo_osv_loader_dir)
    shutil.copy2(result_osv_loader_index_file, repo_osv_loader_dir)

    return capstan_root


def test_recipe(recipe):
    """
    test_recipe() composes and runs demo for given recipe and verifies that unikernel printed expected text to console.
    :param recipe: Recipe instance
    :return: True if test was successfule, False if not
    """
    _print_ok('Testing recipe %s' % recipe.name)

    capstan_root = prepare_test_capstan_root()

    print('Generating package.yaml based on package.yaml.templ template.')
    content = ''
    with open(recipe.demo_yaml_templ, 'r') as f:
        content = f.read()
    content = content.replace('${PACKAGE_NAME}', recipe.name)
    with open(recipe.demo_yaml, 'w') as f:
        f.write(content)

    print('capstan package compose demo (demo_pkg_dir=%s)' % recipe.demo_pkg_dir)
    p = subprocess.Popen(
        'capstan package compose demo'.split(),
        cwd=recipe.demo_pkg_dir,
        env={
            'CAPSTAN_ROOT': capstan_root,
            'PATH': os.environ.get('PATH'),
        },
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    output, error = p.communicate()

    if p.returncode != 0:
        _print_err('"capstan package compose" returned non-zero status code for package %s:' % recipe.demo_pkg_dir)
        print('--- STDOUT: ---\n%s' % output)
        print('--- STDERR: ---\n%s' % error)
        return False

    print('capstan run demo')
    p = subprocess.Popen(
        'capstan run demo'.split(),
        cwd=recipe.demo_pkg_dir,
        env={
            'CAPSTAN_ROOT': capstan_root,
            'PATH': os.environ.get('PATH'),
        },
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    output, error = p.communicate()

    if p.returncode != 0:
        _print_err('"capstan run" returned non-zero status code for package %s:' % recipe.demo_pkg_dir)
        print('--- STDOUT: ---\n%s' % output)
        print('--- STDERR: ---\n%s' % error)
        return False

    print('Checking if unikernel stdout is as expected')
    expected = ''
    with open(recipe.demo_expect, 'r') as f:
        expected = f.read()
    expected = expected.strip()
    expected = re.sub('\s+', '\\s+', expected).strip()
    expected = expected.replace('(', '\(').replace(')', '\)')
    is_ok = re.search(expected, output) is not None

    if not is_ok:
        _print_err('Unikernel stdout is not as expected')
        print('expected =\n%s' % expected)
        print('obtained =\n%s' % output)
        return False

    print('Cleanup')
    shutil.rmtree(capstan_root, ignore_errors=True)

    return True


def test_recipe_list(recipes):
    """
    test_recipe_list() tests all recipes that have demo package in place. Make sure that recipes are
    built and provided prior calling this function.
    :param recipes: list of Recipe instances
    :return: list of failed recipes
    """
    _print_ok('Testing recipes')

    failed_recipes = []
    for recipe in recipes:
        if recipe.has_demo_package:
            TIMER.start()
            if test_recipe(recipe):
                print('Test for %s passed.' % recipe.name)
            else:
                _print_err('Test for %s failed.' % recipe.name)
                failed_recipes.append(recipe)
            TIMER.report('test recipe')
        else:
            _print_warn('Recipe %s contains no demo package' % recipe.name)

    if failed_recipes:
        _print_err('Testing recipes failed for following recipes:\n%s' % '\n'.join(['- ' + r.name for r in recipes]))
    else:
        _print_ok('All tests passed without errors.')

    return failed_recipes


def override_global_variables():
    global SHARE_OSV_DIR
    SHARE_OSV_DIR = env_bool('SHARE_OSV_DIR')

    if SHARE_OSV_DIR:
        _print_warn('OSv source directory will be shared due to SHARE_OSV_DIR being set. Recipes may interfere.')


def env_bool(name, default='no'):
    """
    env_bool() returns True if environment variable is set and False otherwise.
    :param name: name of the environment variable
    :return: boolean
    """
    return os.environ.get(name, default).lower() in ['y', 'yes', 'true', '1']


if __name__ == '__main__':
    override_global_variables()
    prepare_osv_scripts()
    prepare_log_dir()
    recipes = select_recipes(os.environ.get('RECIPES'))
    print('Recipes are:\n%s' % '\n'.join(['- ' + r.name for r in recipes]))

    clear_result_dir_specific(recipes) if env_bool('KEEP_RECIPES', 'yes') else clear_result_dir()
    provide_loader_image()

    build_and_provide_recipe_list(recipes)

    if env_bool('SKIP_TESTS'):
        _print_warn('Skipping all tests since SKIP_TESTS environment variable is set')
    else:
        recipes = select_recipes(os.environ.get('TEST_RECIPES'))
        test_recipe_list(recipes)

    TIMER.report_global()

