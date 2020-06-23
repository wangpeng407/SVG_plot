#!/usr/bin/perl -w

use lib "/Users/wangpeng/novo2019/Perl/module/SVG-2.84/lib";
use SVG;


my ($input, $outfile) = @ARGV;

open IN, $input || die $!;
my (%data, @names, @mnms);
while(<IN>){
	chomp;
	my @temp = split /\t+/;
	$data{$temp[0]} = $temp[1];
	$. < 3 && push @mnms, $temp[0];
	$. >= 3 && push @names, $temp[0];
}
close IN;




my $w = 1000;
my $h = 1000;
my $svg = SVG->new(width=>$w, height=>$h);
my $pi = 4*atan2(1, 1);


my $num = scalar(@names);
my @array = map{360/$num*($_-1)} (1..$num);
my $each_angle = 360/$num;
my $r2 = $w/2*0.5;
my $r1 = 0.5*$r2;

my ($eclipse_rx, $eclipse_ry);

if($num >= 35){
	$eclipse_rx = eval{2*$pi*$r2/$num*0.6};
	$eclipse_rx = $eclipse_rx <= ($w - $r2*2)/4/2.5 ? $eclipse_rx : ($w - $r2*2)/4/2.5;
	$eclipse_ry = $eclipse_rx * 2.5;
}else{
	$eclipse_ry = (400 - $r2-30)/2;
	$eclipse_rx = $eclipse_ry / 2.5;
}


my $i = 0;
for my $n (0..$#names){
	my $angle = $array[$n];
	my $name = $names[$n];
	my $num = $data{$name};
	my $group=$svg->group('transform',"rotate($angle 400,400)", 'fill', 'orange');
	$group->ellipse('cx',400,'cy',400-$eclipse_ry-$r2,'rx',$eclipse_rx,'ry',$eclipse_ry,'fill-opacity','0.5');
	my $nangle = n_angle($angle);
	my $cx = 400 + sin($nangle)*($r2+$eclipse_ry*2);
	my $cy = 400 - cos($nangle)*($r2+$eclipse_ry*2);
	my $va = $angle <= 180 ? $angle - 90 : $angle + 90;
	my $pos = text_position($angle);
	$svg->text('x',$cx, 'y', $cy, '-cdata',"$name", 'text-anchor',$pos, 
			'font-size', '12', 'transform', "rotate($va, $cx, $cy)");
	
	my $group2=$svg->group('transform',"rotate($angle 400,400)");
	$group2->text('x',400, 'y',400-$eclipse_ry-$r2, '-cdata',"$num",
				  'text-anchor','middle', 'font-size', '12');
	
}

$svg->circle('cx',400,'cy',400,'r',$r1,'fill','orange','fill-opacity', '1');
$svg->circle('cx',400,'cy',400,'r',$r2,'fill','blue','fill-opacity', '0.5');
$svg->text( 'x',400, 'y',400-$r2/1.5, '-cdata',"$mnms[0] ($data{$mnms[0]})", 'text-anchor','middle');
$svg->text( 'x',400, 'y',400, '-cdata',"$mnms[1] ($data{$mnms[1]})", 'text-anchor','middle');


my $out = $svg->xmlify;

open OUT, ">", $outfile;

print OUT $out;

close OUT;


sub text_position{
	my ($ang) = @_;
	if($ang == 0 || $ang == 180){
		return 'start';
	}elsif($ang < 180 && $ang > 0){
		return 'start';
	}else{
		return 'end';
	}
}

sub n_angle{
	my ($a) = @_;
	return (2*$pi*$a/360);
}
