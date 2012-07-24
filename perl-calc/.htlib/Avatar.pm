package Avatar;
$|=1;

package Avatar::Face;

use constant TYPE => {
    0 => "(�L�[`)",
    1 => "( ߄t�)",
    2 => "( ��֥)",
    3 => "( ^�Q^)",
};

package Avatar::Hair;

use constant TYPE => {
    0 => "�@",
    1 => "&nbsp;J",
    2 => "�^",
    3 => "&nbsp;S",
    4 => ".�",
    5 => "��",
};

package Avatar::Gender;

use constant TYPE => {
    0 => "�j",
    1 => "��",
};

package Avatar::Blender;

use constant FORMAT => "%s%s%s<br />\n%s<br />\n%s<br />\n%s<br />\n";


sub replaceWhiteSpace
{
    my $str = shift;
    $str =~ s/ {2}/�@/g;
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
