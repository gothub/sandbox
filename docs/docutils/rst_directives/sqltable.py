'''Implements the SQLTable docutils directive.

License
  ::

    This work was created by participants in the DataONE project, and is
    jointly copyrighted by participating institutions in DataONE. For
    more information on DataONE, see our web site at http://dataone.org.
    
      Copyright 2011
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
      http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.


SQLTable is an extension to docutils reStructuredText processor which adds
the ability to pull table content from an SQL data source, a CSV file, or
an Excel spread sheet. SQLManager_ is a convenient tool for working with
SQLite databases.

Project: DataONE
Author: Dave Vieglais

Example for use in Sphinx, add to conf.py after ``import sys, os``::

  #Import the SQLTable directive RST extension
  from sqltable import SQLTable
  from docutils.parsers.rst import directives
  directives.register_directive('sql-table', SQLTable)

.. _SQLManager: http://code.google.com/p/sqlite-manager/

'''

__docformat__ = 'reStructuredText'

import sys
import os.path
import csv
import logging

from docutils import io, nodes, statemachine, utils
from docutils.utils import SystemMessagePropagation
from docutils.parsers.rst import Directive
from docutils.parsers.rst import directives
from docutils.parsers.rst.directives import tables

class SQLTable(tables.Table):
  '''
  '''
  required_arguments = 3
  optional_arguments = 5
  final_argument_whitespace = True
  has_content = True
  option_spec = {'header': directives.unchanged,
                 'widths': directives.positive_int_list,
                 'encoding': directives.encoding,
                 'stub-columns': directives.nonnegative_int, 
                 'class': directives.class_option, 
                 'driver': directives.unchanged_required,
                 'source': directives.unchanged_required,
                 'sql': directives.unchanged_required,
                 } 
  
  
  def check_requirements(self):
    pass
  
  
  def run(self):
    try:
      self.check_requirements()
      stub_columns = self.options.get('stub-columns', 0)
      title, messages = self.make_title()
      table_body, max_cols = self.get_sql_data()
      table_head = self.process_header_option()
      col_widths = self.get_column_widths(max_cols)
      self.check_table_dimensions(table_body, 0, stub_columns)
      self.extend_short_rows_with_empty_cells(max_cols,
                                              (table_head, table_body))
    except SystemMessagePropagation, detail:
      return [detail.args[0]]
    except csv.Error, detail:
      error = self.state_machine.reporter.error(
          'Error with SQL data in "%s" directive:\n%s'
          % (self.name, detail), nodes.literal_block(
          self.block_text, self.block_text), line=self.lineno)
      return [error]
    table = (col_widths, table_head, table_body)
    table_node = self.state.build_table(table, self.content_offset, stub_columns)
    table_node['classes'] += self.options.get('class', [])
    if title:
      table_node.insert(0, title)
    return [table_node] + messages


  def process_header_option(self):
    '''Returns table_head
    '''
    res = []
    colnames = self.options.get('header','')
    for col in colnames.split(','):
      res.append([0,0,0, statemachine.StringList(col.strip().splitlines())])
    return [res, ]


  def get_sql_data(self):
    '''Returns rows, max_cols
    '''
    #Load the specified driver and get a connection to the database
    driver = self.options.get('driver','xlsx')
    if driver == 'xlsx':
      #Load content to an in-memory SQLite database.
      #Yeah, it's ugly, but it works pretty well actually.
      from utils.xls2sql import Xls2Sql
      import sqlite3
      dbconn = sqlite3.connect(':memory:')
      loader = Xls2Sql(dbconn)
      loader.load(self.options.get('source', 'data.xlsx'))
    else:
      default_src = 'database="data.xlsx",driver="xslx"'
      default_src = 'database="csv-data",driver="csv"'
      exec('import %s as DBDRV' % self.options.get('driver', 'SnakeSQL'))
      cnstr = 'dbconn = DBDRV.connect(%s)' % self.options.get('source', default_src)
      exec(cnstr)
    cursor = dbconn.cursor()
    SQL = str(self.options.get('sql'))
    res = cursor.execute(SQL)
    rows = []
    max_cols = 0
    row = cursor.fetchone()
    while row is not None:
      row_data = []
      for cell in row:
        cell_text = unicode(cell)
        cell_data = (0,0,0, statemachine.StringList(
                     cell_text.splitlines()))
        row_data.append(cell_data)
      rows.append(row_data)
      max_cols = max(max_cols, len(row_data))
      row = cursor.fetchone()
    dbconn.close()
    return rows, max_cols
  
