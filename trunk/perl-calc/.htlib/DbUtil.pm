package DbUtil;
$|=1;
use DBI;
use LocalConfig;
use base qw( LocalConfig );

use constant USER   => $LocalConfig::USER   ;
use constant PASSWD => $LocalConfig::PASSWD ;
use constant DBNAME => $LocalConfig::DBNAME ;
use constant SERVER => $LocalConfig::SERVER ;


sub getDbHandler
{
    my $handle = DBI->connect('DBI:mysql:' . DBNAME . ':' . SERVER, USER, PASSWD);
    $handle->do("set names sjis"); 
    return $handle;
}

1;
