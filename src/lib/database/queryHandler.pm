# #####################################################################################################
# 	Script:
# 		queryHandler.pm
#
# 	Description:
#		This script common query statements
#
# 	Author:
#		renanpelicari@gmail.com
#
#	Revision:
#		1.0b	- 2017-11-09	- First version
#
# #####################################################################################################

package queryHandler;

#############################################################################
# imports essentials
#############################################################################
use strict;
use warnings;
use Exporter qw(import);

# lib to handle with database
use DBI;

# include project definitions
use globalDefinitions qw(true);
use projectDefinitions qw(DEFINED_DATABASE);

# import connection handler
use lib '../utils';
require 'messageUtils.pm';
require 'connectionHandler.pm';

#############################################################################
# routine to get element
# params:
#   $query -> string containing the sql query
#
# return:
#   only one element - the value for field in select query
#############################################################################
sub getElement {
    my $query = $_[0];

    if ($globalDefinitions::_DEBUG_MODE) {messageUtils::showDebug("Sub - getElement", $query);}

    my $db = connectionHandler::dbConnect();

    my $sth = $db->prepare($query);
    $sth->execute();

    my @data = $sth->fetchrow_array();

    my $elem = $data[0];

    connectionHandler::dbFinishStatement($sth);
    connectionHandler::dbDisconnect($db);

    return $elem;
}

#############################################################################
# routine to get a list of elements
# params:
#   $query -> string containing the sql query
#
# return:
#   list of elements - the values for field in select query (just for one field)
#############################################################################
sub getElements {
    my $query = $_[0];

    if ($globalDefinitions::_DEBUG_MODE) {messageUtils::showDebug("Sub - getElements", $query);}

    my $db = connectionHandler::dbConnect();

    my $sth = $db->prepare($query);
    $sth->execute();

    my @data = $sth->fetchrow_array();

    connectionHandler::dbFinishStatement($sth);
    connectionHandler::dbDisconnect($db);

    return @data;
}

#############################################################################
# routine to get last element and increment one, generating a new element
# ps: used mainly for sequence attributes (PK), like ID
# params:
#   $query -> string containing the sql query
#
# return:
#   the new element
#############################################################################
sub getNewElement {
    my $query = $_[0];

    my $element = getElement($query);

    return ++$element;
}

#############################################################################
# routine that check if element exists
# params:
#   $query -> string containing the sql query
#
# return:
#   1/0 (true or false)
#############################################################################
sub exists {
    return getElement($_[0]) ne 0;
}

#############################################################################
# select any element (exclusive for Oracle)
# params:
#   table   -> table name
#   column  -> the selected column
#   orderBy -> column used by criteria to order (null in case of random)
# return:
#   string with query
#############################################################################
sub selectAnyOracle {
    my $table = $_[0];
    my $column = $_[1];
    my $orderBy = defined($_[2]) ? $_[2] : "DBMS_RANDOM.VALUE";

    my $query = join(" ", "SELECT", $column,
        "FROM (SELECT", $column, "FROM", $table, "ORDER BY", $orderBy, "DESC) WHERE ROWNUM = 1");

    return $query;
}

#############################################################################
# select one element
# params:
#   table           -> table name
#   response        -> the value of column that will return as response
#   criteria        -> the criteria column to compare
#   value           -> criteria value
# return:
#   string with query
#############################################################################
sub selectOne {
    return join(" ", "SELECT", $_[0], "FROM", $_[1], "WHERE", $_[2], "=", $_[3]);
}

#############################################################################
# check the with database is used and call the right implementation
# params:
#   table   -> table name
#   column  -> the selected column
#   orderBy -> column used by criteria to order (null in case of random)
# return:
#   string with query
#############################################################################
sub selectAny {
    # check database definition
    if (DEFINED_DATABASE eq 'ORACLE') {
        return selectAnyOracle($_[0], $_[1], $_[2]);
    }

    die "FATAL ERROR: Database connection is not defined!"
}

#############################################################################
# routine to execute query and return the result of execution
# whit the return is possible to handle with record set as you wish
# params:
#   $query -> string containing the sql query
#
# return:
#   the result of statement handle execution
#############################################################################
sub execute {
    my $query = $_[0];

    if ($globalDefinitions::_DEBUG_MODE) {messageUtils::showDebug("Sub - getElements", $query);}

    my $db = connectionHandler::dbConnect();

    my $sth = $db->prepare($query);
    $sth->execute();
}

#############################################################################
return true;
