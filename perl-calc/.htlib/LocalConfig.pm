package LocalConfig;
$|=1;

$LocalConfig::BASE_DIR = "/home/hoge";
$LocalConfig::DATA_PLACE = "$LocalConfig::BASE_DIR/data";
$LocalConfig::TEMPLATE_DIR = "$LocalConfig::DATA_PLACE/hoge";
$LocalConfig::LOG_DIR = "$LocalConfig::BASE_DIR/.htlog";

$LocalConfig::ACCESS_LOG = "aa_access_log";
$LocalConfig::SYSTEM_LOG = "aa_system_log";
$LocalConfig::ROTATE = "1";



$LocalConfig::BASE_URL = 'http://hogehoge.net';
$LocalConfig::USER   = 'hoge';
$LocalConfig::PASSWD = 'hoge';
$LocalConfig::DBNAME = 'hoge';
$LocalConfig::SERVER = 'localhost';
$LocalConfig::LOCAL_DEBUG = 1;


1;
