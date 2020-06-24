#!/usr/bin/perl -w
use strict;
use warnings;
use lib "/Users/wangpeng/novo2019/Perl/module/SVG-2.84/lib";
use SVG;
use List::Util qw(max min sum);

my @testy = qw/0 0.34 -0.10 0.4 0.5 0.6 0.20 0.9/;
my @testx = qw/0 1 2 3 4 5 6 7/;
my @testl = qw/A B C D E F G H/;
my @lable = qw/A B C D E/;
my @prop = qw/0.2 0.1 0.6 0.2 1/;
my @color = qw/red blue green pink purple/;

my $width = 1000;
my $height = 600;
my $svg = SVG->new('width', $width, 'height', $height);

my $fontsize ||= 20;
my $margin = 40;
my $tick_len = 10;
my ($flank_x1, $flank_x2, $flank_y1, $flank_y2) = (100, 50, 100, 50);

my %argsx = (width=>$width, flank1=>$flank_x1, flank2=>$flank_x2,
			margin=>$margin, tick_num=>7, every_tick_num=>1, 
			fontsize=>$fontsize, seqnum=>\@testl, numtype=>'N');
my %argsy = (width=>$height, flank1=>$flank_y1, flank2=>$flank_y2,
			margin=>$margin, tick_num=>10, every_tick_num=>1, 
			fontsize=>$fontsize, seqnum=>\@testy);

my %resx = detailed_region_define(%argsx); my %resy = detailed_region_define(%argsy);
my($xs, $xe) = @{$resx{side}}; my($ys, $ye) = @{$resy{side}};
my $tick_numx = $resx{tick_num}; my $tick_numy = $resy{tick_num};
my $every_tick_numx = $resx{every_tick_num}; my $every_tick_numy = $resy{every_tick_num};
my $step_lenx = $resx{step_len}; my $step_leny = $resy{step_len};
my ($minx, $maxx)= @{$resx{minmax}}; my ($miny, $maxy)= @{$resy{minmax}};
my $x_num_interval= $resx{num_interval}; my $y_num_interval= $resy{num_interval};
my @xseries = @{$resx{series}}; my @yseries = @{$resy{series}};
my $max_font_lenx = $resx{max_font_len}; my $max_font_leny = $resy{max_font_len};
my $fontsizex = $resx{fontsize}; my $fontsizey = $resy{fontsize};


my $x = $svg->group(id=>'group_x', style=>{'stroke'=>'black','stroke-width',2} );
my $y = $svg->group(id=>'group_y', style=>{'stroke'=>'red','stroke-width',2} );
my $z = $svg->group(id=>'group_z', style=>{'stroke'=>'black','stroke-width',1, 'stroke-opacity',0.5} );
my $text = $svg->group(id=>'group_t', style=>{'color'=>'red','text-anchor','middle','font-family','Arial'});
my $circle = $svg->group(id=>'group_c', style => {'fill'=>'blue','stroke'=>'black','stroke-width'=>5,'stroke-opacity'=>0.3,'fill-opacity'=>0.6} );
my $rct = $svg->group(id=>'group_rct', fill=>'blue','fill-opacity'=>0.8,'stroke-width'=>3,'stroke-opacity'=>0.3);
my $n = $tick_numx >= $tick_numy ? $tick_numx : $tick_numy >= $#testx+1 ?  $tick_numy: $#testx+1;
for my $i (0..$n){
	my $xlable = $xseries[$i];
 	my $ylable = $yseries[$i];
	if($i % $every_tick_numx == 0 && $i <= $tick_numx){
		$x->line(x1=>$xs+$i*$step_lenx+$margin, y1=>ct_y($ys, $height),
 		     x2=>$xs+$i*$step_lenx+$margin, y2=>ct_y($ys-$tick_len, $height));
 		$svg->text( 'x',$xs+$i*$step_lenx+$margin,
 				'y',ct_y($ys-$tick_len-$fontsizex, $height),
 			    '-cdata',$xlable, 'font-size',$fontsizex,'text-anchor','middle' 
 			   );
	}
	if($i % $every_tick_numy == 0 && $i <= $tick_numy){
		$x->line(x1=>$xs, y1=>ct_y($ys+$i*$step_leny+$margin, $height),
 				 x2=>$xs-$tick_len, y2=>ct_y($ys+$i*$step_leny+$margin, $height));
 		$svg->text('x',$xs-$tick_len*1.2,
				   'y',ct_y($ys+$i*$step_leny+$margin-$fontsizey/2, $height),
 				   '-cdata',$ylable, 'font-size', $fontsizey, 'text-anchor','end');	
	}
 			    
 	if($i <= $#testx){
 		my $rec_widht = 80;
 		my $xp = $xs+($testx[$i]-$minx)/$x_num_interval*$step_lenx+$margin;
 		my $xp2 = $xs+($testx[$i]-$minx)/$x_num_interval*$step_lenx+$margin-$rec_widht/2;
 		my $yp = ct_y($ys+($testy[$i]-$miny)/$y_num_interval*$step_leny+$margin, $height);
# 		$circle->circle(cx => $xp, cy => $yp, r  => 10);
		$rct->rectangle(x=>$xp2, y=>$yp, width=>$rec_widht, height=>$height-$yp-$flank_y1);
		#pie
		my $r = $rec_widht/2;
		my($x0, $y0) = ($xp, $yp-$r-5);
		my %pp = point_position_determine_in_circles($height, $width, $x0, $y0, $r, \@prop);
		for my $i (0..$#prop){
			my ($px1, $py1, $angle1) = @{$pp{$i+1}};
			my ($px2, $py2, $angle2) = @{$pp{$i+2}};
			$i>$#prop && next;
			my $large01 = $angle2 >= 180 ? 1 : 0;
			$svg->path('d'=>"M $x0 $y0 A 0 0 0 0 0 $x0 $y0
					 L $px1 $py1 
					 A $r $r 0 $large01 1 $px2 $py2 Z",
			   		 'fill'=>$color[$i],'fill-opacity'=>1, 'stroke-width'=>2,
			   		 "stroke"=>'black', 'stroke-opacity'=>'1');
}
 	}
}

my $x_x0 = ($xe-$xs)/2+$flank_x1;
my $x_y0 = ct_y($ys-2*($tick_len+$fontsizex), $height);
$svg->text('x', $x_x0, 'y', $x_y0,'-cdata','x_lable', 'font-size', $fontsizex, 
 			'text-anchor','middle', 
 			'transform', "rotate(0, $x_x0, $x_y0)");

my $y_x0 = $xs-$tick_len-($max_font_leny+2)/2*$fontsizey;
my $y_y0 = ct_y(($ye - $ys)/2 + $flank_y1, $height);
$svg->text('x', $y_x0, 'y', $y_y0,
 			'-cdata',"y_lable", 'font-size', $fontsizey, 
 			'text-anchor','middle', 
 			'transform', "rotate(-90, $y_x0, $y_y0)");
#outluier 
#$y->line(x1=>5, y1=>5, x2=>$width-5, y2=>5 );
#$y->line(x1=>5, y1=>5, x2=>5, y2=>$height-5 );
#$y->line(x1=>5, y1=>$height-5, x2=>$width-5, y2=>$height-5 );
#$y->line(x1=>$width-5, y1=>5, x2=>$width-5, y2=>$height-5 );
#plot region
$x->line(x1=>$xs, y1=>ct_y($ys, $height),
 		 x2=>$xe, y2=>ct_y($ys, $height));	 
$x->line(x1=>$xs, y1=>ct_y($ys, $height), 
		 x2=>$xs, y2=>ct_y($ye, $height));		 
#$x->line(x1=>$xs, y1=>ct_y($ye, $height), 
#		 x2=>$xe, y2=>ct_y($ye, $height));
#$x->line(x1=>$xe, y1=>ct_y($ys, $height), 
#		 x2=>$xe, y2=>ct_y($ye, $height));
		 
open OUT, ">", "bar.pie.svg";
print OUT $svg->xmlify;
close OUT;


sub ct_y{
	my ($num, $height) = @_;
	return($height - $num);
}

sub format_num{
	my ($num) = @_;
	my ($sur, $pref) = (split /\./, $num);
	my ($npos, $zeros);
	if($sur > 0){
		$npos = length($sur) >=3 ? 0 : 1;
	}else{
		$zeros = $1 if $pref && $pref =~ /^(0+)[^0]/;
		$npos = (defined($zeros) && $zeros ne '') ? length($zeros) + 1 : 1;
	}
	my $tmp = "%.$npos" . 'f';
	my $finalnum = sprintf($tmp, $num);
	return($finalnum, $tmp);
}

sub detailed_region_define{
	my (%args) = @_;
	my($width, $flank1, $flank2, $margin, $tick_num, $every_tick_num, $fontsize, $seqnum, $type) = 
	  ($args{width}, $args{flank1}, $args{flank2}, $args{margin}, $args{tick_num},
	   $args{every_tick_num}, $args{fontsize}, $args{seqnum}, $args{numtype});
	
	$type ||= 'T';
	my @seq = $type eq 'T' ? @{$seqnum} : (0..scalar(@{$seqnum})-1);
	print $type, "\t", join("\t", @seq), "\n";
	my($step_lenx, @minmax, $x_num_interval, @xseries, $max_font_len, $xnps, $maxp);
	my $pwdith = $width - $flank1 - $flank2;
	my $xs = $flank1;
	my $xe = $flank1 + $pwdith;
	my @side_pos = ($xs, $xe);
	my $tw = $xe - $xs - 2*$margin;
	$tick_num ||=scalar(@testx)+1;
	$every_tick_num ||= 1;
	do
	{
		$step_lenx = ($tw / $tick_num);
		my $minx = (format_num(min(@seq)))[0];
		my $maxx = (format_num(max(@seq)))[0];
		@minmax = ($minx, $maxx); 
		my @x_p = format_num(($maxx-$minx)/$tick_num);
		$x_num_interval = $x_p[0]; $xnps = $x_p[1];
		@xseries = $type eq 'T' ? map{ sprintf($xnps, $minx+$_*$x_num_interval) } (0..$tick_num) : 
								@{$seqnum};
		if($type eq 'T'){
			$max_font_len = max(@xseries)=~/\./ ? length(max(@xseries))-1 : length(max(@xseries))
		}else{
			my @len_series = map{ length($_) } @xseries;
			$max_font_len = max(@len_series)+1;
		}
		$fontsize ||= 40 - $max_font_len*5;
		$maxp = ct_y($xs+(max(@seq)-$minx)/$x_num_interval*$step_lenx+$margin, $width);
		$tick_num++;
	}while($maxp<ct_y($xe, $width));
	
	my %res;
	$res{side} = \@side_pos;
	$res{tick_num} = $tick_num-1;
	$res{every_tick_num} = $every_tick_num;
	$res{step_len} = $step_lenx;
	$res{minmax} = \@minmax;
	$res{num_interval} = $x_num_interval;
	$res{series} = \@xseries;
	$res{max_font_len} = $max_font_len;
	$res{fontsize} = $fontsize;
	return %res;
}

sub point_position_determine_in_circles{
	my($height, $width, $cx0, $cy0, $r, $data) = @_;
	sub arc_position{
		my ($height, $cx0, $cy0, $angle, $r) = @_;
		my $y = ct_y($r*cos($angle)+$cy0, $height);
		my $x = $r*sin($angle)+$cx0;
		return($x, $y);
	}
	my %res;
	my $pi = 4*atan2(1, 1);
	$cy0 = ct_y($cy0, $height);
	my @data = @{$data};
	my $sum = sum(@data);
	my $arcx0 = $cx0;
	my $arcy0 = ct_y($cy0+$r, $height);
	my @pointxy1 = ($arcx0, $arcy0);
	$res{1} = \@pointxy1;
	my $angle = 0;
	for my $i (0..$#data){
		$angle += $data[$i]/$sum*2*$pi;
		my $real_angle = $data[$i]/$sum*360;
		my @pointxy = arc_position($height, $cx0, $cy0, $angle, $r);
		push @pointxy, $real_angle;
		$res{$i+2} = \@pointxy;
	}
	return(%res);
}

__END__
