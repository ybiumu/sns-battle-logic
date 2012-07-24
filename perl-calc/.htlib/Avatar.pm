package Avatar;
$|=1;

package Avatar::Face;

use constant TYPE => {
    0 => "(ÅLÅ[`)",
    1 => "( ﬂÑtﬂ)",
    2 => "( •É÷•)",
    3 => "( ^ÅQ^)",
};

package Avatar::Hair;

use constant TYPE => {
    0 => "Å@",
    1 => "&nbsp;J",
    2 => "Å^",
    3 => "&nbsp;S",
    4 => ".•",
    5 => "É∞",
};

package Avatar::Gender;

use constant TYPE => {
    0 => "íj",
    1 => "èó",
};

package Avatar::Blender;

use constant FORMAT => "%s%s%s<br />\n%s<br />\n%s<br />\n%s<br />\n";


sub replaceWhiteSpace
{
    my $str = shift;
    $str =~ s/ {2}/Å@/g;
    $str =~ s/ /&nbsp;/g;
    return $str;
}

sub outputAvatar
{
    my $h = shift;
    my $f = shift;
    my @o = @_;
    return sprintf(FORMAT, replaceWhiteSpace($h),replaceWhiteSpace($f), ( map {replaceWhiteSpace($_)} @o[0 .. 3]) );
}


1;
