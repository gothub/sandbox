'''Implements the CSVFTable docutils directive.

License
  ::

    This work was created by participants in the DataONE project, and is
    jointly copyrighted by participating institutions in DataONE. For
    more information on DataONE, see our web site at http://dataone.org.
    
      Copyright 2010
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
      http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

'''

__docformat__ = 'reStructuredText'

import sys
import os.path
import csv

from docutils import io, nodes, statemachine, utils
from docutils.utils import SystemMessagePropagation
from docutils.parsers.rst import Directive
from docutils.parsers.rst import directives
from docutils.parsers.rst.directives import tables

class CSVFTable(tables.CSVTable):
  '''Extends docutils_ csvtable_ by adding a columns parameter to specify
  which columns from the data source are to be rendered.

  .. _docutils: http://docutils.sourceforge.net
  .. _csvtable: http://docutils.sourceforge.net/docs/ref/rst/directives.html#id1
  '''
  
  option_spec = {'header-rows': directives.nonnegative_int,
               'stub-columns': directives.nonnegative_int,
               'header': directives.unchanged,
               'widths': directives.positive_int_list,
               'file': directives.path,
               'url': directives.uri,
               'encoding': directives.encoding,
               'class': directives.class_option,
               # field delimiter char
               'delim': directives.single_char_or_whitespace_or_unicode,
               # treat whitespace after delimiter as significant
               'keepspace': directives.flag,
               # text field quote/unquote char:
               'quote': directives.single_char_or_unicode,
               # char used to escape delim & quote as-needed:
               'escape': directives.single_char_or_unicode,
               'columns': directives.positive_int_list, }


  def get_columns(self):
    columns = None
    if 'columns' in self.options:
      columns = self.options['columns']
    return columns


  def parse_csv_data_into_rows(self, csv_data, dialect, source):
      columns = self.get_columns()
      if columns is None:
        return super(CSVFTable, self).parse_csv_data_into_rows(csv_data, 
                                                               dialect, 
                                                               source)
      # csv.py doesn't do Unicode; encode temporarily as UTF-8
      csv_reader = csv.reader([self.encode_for_csv(line + '\n')
                               for line in csv_data],
                              dialect=dialect)
      rows = []
      max_cols = len(columns)
      for row in csv_reader:
        row_data = ['']*len(columns)
        i = 1
        for cell in row:
          if i in columns:
            cell_text = self.decode_from_csv(cell)
            cell_data = (0, 0, 0, statemachine.StringList(
                cell_text.splitlines(), source=source))
            row_data[columns.index(i)] = cell_data
          i += 1
        rows.append(row_data)
      return rows, max_cols
  
