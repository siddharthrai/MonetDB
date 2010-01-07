#!perl -I./t

# The contents of this file are subject to the MonetDB Public License
# Version 1.1 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://monetdb.cwi.nl/Legal/MonetDBLicense-1.1.html
#
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
# License for the specific language governing rights and limitations
# under the License.
#
# The Original Code is the MonetDB Database System.
#
# The Initial Developer of the Original Code is CWI.
# Portions created by CWI are Copyright (C) 1997-July 2008 CWI.
# Copyright August 2008-2010 MonetDB B.V.
# All Rights Reserved.

$| = 1;

use strict;
use warnings;
use DBI();
use DBD_TEST();

use Test::More;

if (defined $ENV{DBI_DSN}) {
  plan tests => 26;
} else {
  plan skip_all => 'Cannot test without DB info';
}

pass('Table info tests');

my $dbh = DBI->connect or die "Connect failed: $DBI::errstr\n";
pass('Database connection created');

my $tbl = lc $DBD_TEST::table_name;

ok( DBD_TEST::tab_create( $dbh ),"CREATE TABLE $tbl");
{
  my @names = qw(TABLE_CAT TABLE_SCHEM TABLE_NAME TABLE_TYPE REMARKS);
  my $sth = $dbh->table_info;
  my $rows = 0;
  while ( my $row = $sth->fetch ) {
    $rows++;
  }
  my $names = $sth->{NAME_uc};
  is( $names->[$_], $names[$_],"Column: $names->[$_] $names[$_]")
    for 0 .. $#names;

  is( $dbh->tables, $rows,"Total tables count: $rows");
}
{
  my $sth = $dbh->table_info( undef, undef, undef,'TABLE');
  ok( defined $sth,'Statement handle defined');

  my $row = $sth->fetch;
  is( $row->[3],'TABLE','Fetched a TABLE?');
}
{
  my $sth = $dbh->table_info( undef, undef, $tbl,'TABLE');
  ok( defined $sth,'Statement handle defined');

  my $row = $sth->fetch;
  is( $row->[2], $tbl,"Is this $tbl?");
  is( $row->[3],'TABLE',"Is $tbl a TABLE?");
}
{
  my $sth = $dbh->table_info( undef, undef, $tbl,'VIEW');
  ok( defined $sth,'Statement handle defined');

  my $row = $sth->fetch;
  ok( !defined $row,"$tbl isn't a VIEW!");
}
=for todo
{
  my $sth = $dbh->table_info('%');
  ok( defined $sth,'Statement handle defined');

  print "Catalogs:\n";
  while ( my $row = $sth->fetch )
  {
    local $^W = 0;
    local $,  = "\t";
    print @$row,"\n";
  }
}
{
  my $sth = $dbh->table_info( undef,'%');
  ok( defined $sth,'Statement handle defined');

  print "Schemata:\n";
  while ( my $row = $sth->fetch )
  {
    local $^W = 0;
    local $,  = "\t";
    print @$row,"\n";
  }
}
{
  my $sth = $dbh->table_info( undef, undef, undef,'%');
  ok( defined $sth,'Statement handle defined');

  print "Table types:\n";
  while ( my $row = $sth->fetch )
  {
    local $^W = 0;
    local $,  = "\t";
    print @$row,"\n";
  }
}
=cut

# -----------------------------------------------------------------------------
{
my $sth;

# Table Info
eval {
  $sth = $dbh->table_info;
};
ok( (!$@ and defined $sth ),'table_info tested');
$sth = undef;

# Tables
eval {
  $sth = $dbh->tables;
};
ok( (!$@ and defined $sth ),'tables tested');
$sth = undef;

# Test Table Info
$sth = $dbh->table_info( undef, undef, undef );
ok( defined $sth,'table_info( undef, undef, undef ) tested');
DBD_TEST::dump_results( $sth );
$sth = undef;

$sth = $dbh->table_info( undef, undef, undef,'VIEW');
ok( defined $sth, q(table_info( undef, undef, undef,'VIEW') tested) );
DBD_TEST::dump_results( $sth );
$sth = undef;

# Test Table Info Rule 19a
$sth = $dbh->table_info('%','','');
ok( defined $sth, q(table_info('%','','') tested) );
DBD_TEST::dump_results( $sth );
$sth = undef;

# Test Table Info Rule 19b
$sth = $dbh->table_info('','%','');
ok( defined $sth, q(table_info('','%','') tested) );
DBD_TEST::dump_results( $sth );
$sth = undef;

# Test Table Info Rule 19c
$sth = $dbh->table_info('','','','%');
ok( defined $sth, q(table_info('','','','%') tested) );
DBD_TEST::dump_results( $sth );
$sth = undef;

# Test to see if this database contains any of the defined table types.
$sth = $dbh->table_info('','','','%');
ok( defined $sth, q(table_info('','','','%') tested) );
if ( $sth ) {
  my $err = 0;
  my $ref = $sth->fetchall_hashref(lc 'TABLE_TYPE');
  for my $type ( sort keys %$ref ) {
    print "# $type:\n";
    my $sth = $dbh->table_info( undef, undef, undef, $type ) or $err++;
    DBD_TEST::dump_results( $sth );
  }
  is( $err, 0,'all table types selected');
}
$sth = undef;

}
# -----------------------------------------------------------------------------

ok( $dbh->disconnect,'Disconnect');
