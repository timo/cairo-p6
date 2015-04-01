use Panda::Builder;

use Shell::Command;
use LWP::Simple;
use NativeCall;

# test sub for system library
sub test() is native('libcairo-2.dll') { * }

class Build is Panda::Builder {
    method build($workdir) {
        my $need-copy = False;

        # we only have .dll files bundled. Non-windows is assumed to have the library already
        if $*DISTRO.is-win {
            test();
            CATCH {
                default {
                    $need-copy = True if $_.payload ~~ m:s/Cannot locate/;
                }
            }
        }

        if $need-copy {
            # to avoid a dependency (and because Digest::SHA is too slow), we do a hacked up powershell hash
            # this should work all the way back to powershell v1
            my &ps-hash = -> $path {
                my $fn = 'function get-sha256 { param($file);[system.bitconverter]::tostring([System.Security.Cryptography.sha256]::create().computehash([system.io.file]::openread((resolve-path $file)))) -replace \"-\",\"\" } ';
                my $out = qqx/powershell -noprofile -Command "$fn get-sha256 $path"/;
                $out.lines.grep({$_.chars})[*-1];
            }
            say 'No system cairo library detected. Installing bundled version.';
            mkdir($workdir ~ '\blib\lib\Cairo');
            my @files = (
                         "libcairo-2.dll",
                         "libfontconfig-1.dll",
                         "libfreetype-6.dll",
                         "libiconv-2.dll",
                         "liblzma-5.dll",
                         "libpixman-1-0.dll",
                         "libpng15-15.dll",
                         "libxml2-2.dll",
                         "zlib1.dll");
            my @hashes = (
                          "E127BF5D01CD9B2F82501E4AD8F867CE9310CE16A33CB71D5ED3F5AB906FD318",
                          "1AC7BC02502D1D798662B3621B43637F33B07424C89E2E808945BD7133694EFA",
                          "7C54CB33D0247E3BB65974CAD1B7205590DF0E99460CF197E37B4CABDE265935",
                          "954B8740A7CBE3728B136D4F36229C599D1F51534137B16E48E3D7FF9C468FDC",
                          "CE34910B43D5E4285AECDA0E4F64A1BA06C5D53E484F0B68D219C8D8473332AB",
                          "A97EBE54ED31ED7D8A8317D831878CE82F3B94FE1E5A7466B78D0F0C90863302",
                          "40F6EDE85DB0A1E2F4BA67693B7DC8B74AFFBFAB3B92B99F6B2CEFACBBF7FF6D",
                          "4F1032F0D7F6F0C2046A96884FD48EC0F7C0A1E22C85E9076057756C4C48E0CB",
                          "5A697F89758B407EE85BAD35376546A80520E1F3092D07F1BC366A490443FAB5");
            for @files Z @hashes -> $f, $h {
                say "Fetching  " ~ $f;
                my $blob = LWP::Simple.get('http://gtk-dlls.p6c.org/' ~ $f);
                say "Writing   " ~ $f;
                spurt($workdir ~ '\blib\lib\Cairo\\' ~ $f, $blob);

                say "Verifying " ~ $f;
                my $hash = ps-hash($workdir ~ '\blib\lib\Cairo\\' ~ $f);
                if ($hash ne $h) {
                    die "Bad download of $f (got: $hash; expected: $h)";
                }
                say "";
            }
        }
        else {
            say 'Found system cairo library.';
        }
    }
}
