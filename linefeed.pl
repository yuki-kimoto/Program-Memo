use strict;
use warnings;

use File::Find;
use File::Copy;
use File::Spec;

my $dir = shift;
die "Usage: $0 dir\n" unless $dir;
$dir = File::Spec->rel2abs($dir);

finddepth(\&wanted, $dir);

sub wanted{
    my $file = $File::Find::name;
    return unless $file =~ m#\Q$dir/lib/# || $file =~ m#\Q$dir/t/#;
    return unless -T $file;
    
    convert_to_line_feed($file);
}

sub convert_to_line_feed {
    my $infile = shift;
    
    open my $infh, "<", $infile
        or die "Cannot open $infile: $!";
    
    my $content = do {
        local $/;
        <$infh>;
    };
    
    close $infh;
    
    $content =~ s/\x0D\x0A|\x0D|\x0A/\x0A/g;
    
    my $outfile = "$infile.new";
    
    open my $outfh, ">", $outfile
        or die "Cannot open $outfile: $!";
    
    print $outfh $content;
    
    close $outfh;
    
    move($outfile, $infile)
        or die "Cannot move $outfile to $infile: $!";
}
