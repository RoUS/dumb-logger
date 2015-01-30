# Copyright © (c) 2015 Ken Coar
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Based on
# https://github.com/dgoodwin/tito/blob/master/src/tito/tagger/main.py
#
"""
Code for tagging Ruby gems based on their <gemname>::VERSION constant.
"""

import os
import re
import rpm
import shutil
import subprocess
import tempfile
import textwrap
import sys

from string import Template

from time import strftime

from tito.common import (debug, error_out, run_command,
                         find_file_with_extension, find_spec_file,
                         get_project_name, get_latest_tagged_version,
                         get_spec_version_and_release,
                         replace_version, tag_exists_locally,
                         tag_exists_remotely, head_points_to_tag,
                         undo_tag, increase_version, reset_release,
                         increase_zstream, BUILDCONFIG_SECTION,
                         get_relative_project_dir_cwd)
from tito.compat import *
from tito.exception import TitoException
from tito.config_object import ConfigObject
from tito.tagger import VersionTagger

class GemTagger(VersionTagger):
    """
    Releases will be tagged by obtaining the value of the VERSION constant
    from the gem.
    """

    def __init__(self, config=None, keep_version=False, offline=False, user_config=None):
        VersionTagger.__init__(self, config=config)
        self.gemspec_file_name = find_file_with_extension(suffix=".gemspec")

    def _tag_release(self):
        """
        Tag a new version of the package based upon the gem version.
        """
        self._make_changelog()
        new_version = subprocess.check_output(
            [
                "ruby",
                "-e",
                "gspec = eval(File.read('" + self.gemspec_file_name + "')); " +
                "print(gspec.version)"
            ])
        self._check_tag_does_not_exist(self._get_new_tag(new_version))
        self._update_changelog(new_version)
        self._update_setup_py(new_version)
        self._update_package_metadata(new_version)

