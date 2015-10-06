package GoogleAdSence;
$|=1;


use LWP::UserAgent;
use Time::HiRes qw(gettimeofday);
use URI::Escape;

use Exporter 'import';
our @EXPORT_OK = qw( get_ad get_fp_ad get_sp_ad );

sub google_append_color {
  my @color_array = split(/,/, $_[0]);
  return $color_array[$_[1] % @color_array];
}

sub google_append_screen_res {
  my $screen_res = $ENV{"HTTP_UA_PIXELS"};
  if ($screen_res == "") {
    $screen_res = $ENV{"HTTP_X_UP_DEVCAP_SCREENPIXELS"};
  }
  if ($screen_res == "") {
    $screen_res = $ENV{"HTTP_X_JPHONE_DISPLAY"};
  }
  my @res_array = split("[x,*]", $screen_res);
  if (@res_array == 2) {
    return "&u_w=" . $res_array[0] . "&u_h=" . $res_array[1];
  }
}


sub get_muid {
  my $muid = $ENV{"HTTP_X_DCMGUID"};
  if ($muid) {
    return $muid;
  }
  $muid = $ENV{"HTTP_X_UP_SUBNO"};
  if ($muid) {
    return $muid;
  }
  $muid = $ENV{"HTTP_X_JPHONE_UID"};
  if ($muid) {
    return $muid;
  }
  $muid = $ENV{"HTTP_X_EM_UID"};
  if ($muid) {
    return $muid;
  }
}

sub google_append_muid {
 return "&muid=" . get_muid();
}

sub google_append_via_and_accept {
  if ($_[0] eq "") {
    my $via_and_accept;
    my $via = uri_escape($ENV{"HTTP_VIA"});
    if ($via) {
      $via_and_accept = "&via=" . $via;
    }
    my $accept = uri_escape($ENV{"HTTP_ACCEPT"});
    if ($accept) {
      $via_and_accept = $via_and_accept . "&accept=" . $accept;
    }
    if ($via_and_accept) {
      return $via_and_accept;
    }
  }
}

sub get_ad
{
    my $at = shift;
    if ( $at->isRelease() )
    {
        if ( $at->getMobileUtil()->getBrowser() eq "P" )
        {
            $at->setAdStr( get_sp_ad() );
        }
        else
        {
            $at->setAdStr( get_fp_ad() );
        }
    }
}

sub get_fp_ad
{
    my $google_dt = sprintf("%.0f", 1000 * gettimeofday());
    my $google_scheme = ($ENV{"HTTPS"} eq "on") ? "https://" : "http://";
    my $google_user_agent = uri_escape($ENV{"HTTP_USER_AGENT"});

    my $google_ad_url = "http://pagead2.googlesyndication.com/pagead/ads?" .
      "client=ca-mb-pub-6767456309495643" .
      "&dt=" . $google_dt .
      "&ip=" . uri_escape($ENV{"REMOTE_ADDR"}) .
      "&markup=xhtml" .
#      "&oe=sjis" .
      "&output=xhtml" .
      "&ref=" . uri_escape($ENV{"HTTP_REFERER"}) .
#      "&slotname=0148237806" .
      "&slotname=8244801244" .
      "&url=" . uri_escape($google_scheme . $ENV{"HTTP_HOST"} . $ENV{"REQUEST_URI"}) .
      "&useragent=" . $google_user_agent .
      google_append_screen_res() .
      google_append_muid() .
      google_append_via_and_accept($google_user_agent);

    my $google_ua = LWP::UserAgent->new;
    my $google_ad_output = $google_ua->get($google_ad_url);
    my $ad_str = undef;
    if ($google_ad_output->is_success) {
        $ad_str .= $google_ad_output->content;
    }


    return $ad_str;
}

sub get_sp_ad
{
    return <<_HERE_
<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<!-- anothark_sp_footer -->
<ins class="adsbygoogle"
     style="display:inline-block;width:320px;height:50px"
     data-ad-client="ca-pub-6767456309495643"
     data-ad-slot="6628467242"></ins>
<script>
(adsbygoogle = window.adsbygoogle || []).push({});
</script>
_HERE_
}
1;
