package LocalConfig;
$|=1;

$LocalConfig::BASE_DIR = "/home/users/2/ciao.jp-anothark/web";
$LocalConfig::DATA_PLACE = "$LocalConfig::BASE_DIR/data";
$LocalConfig::TEMPLATE_DIR = "$LocalConfig::DATA_PLACE/anothark";
$LocalConfig::LOG_DIR = "$LocalConfig::BASE_DIR/.htlog";

$LocalConfig::ACCESS_LOG = "aa_access_log";
$LocalConfig::SYSTEM_LOG = "aa_system_log";
$LocalConfig::ROTATE = "1";



$LocalConfig::BASE_URL = 'http://anothark.colinux.net';
$LocalConfig::USER   = 'mp';
$LocalConfig::PASSWD = 'mp';
$LocalConfig::DBNAME = 'LAA0195285-anothark';
$LocalConfig::SERVER = 'localhost';
$LocalConfig::LOCAL_DEBUG = 1;

#$LocalConfig::BASE_URL = 'http://anothark.ciao.jp';
#$LocalConfig::USER   = 'LAA0195285';
#$LocalConfig::PASSWD = 'krah_tona';
#$LocalConfig::DBNAME = 'LAA0195285-anothark';
#$LocalConfig::SERVER = 'mysql567.phy.lolipop.jp';
#$LocalConfig::LOCAL_DEBUG = 0;

1;
