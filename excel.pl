#!/usr/bin/perl -w
#use strict
#need two argvs,first is the xlsx file name,second is the number
#of the sheet that you want to generate verilog file, start from 0
#eg:  
#    ./excel.pl xxx.xlsx  0
use Spreadsheet::XLSX;
my $excel = Spreadsheet::XLSX -> new (shift @ARGV) or die ("cannot open xlsx");


my @addr;
my @register_name;
my @property;
my @type;

my @field;
my @start;
my @end;
my @field_len;
my @field_name;

my $clk = 'aclk';
my $rst = 'areset';
my @addr_name;

my $i = 0;
my $j = 0;
my $sheet = @{$excel->{Worksheet}}[shift @ARGV] ;
open H, ">$sheet->{Name}.v" or die ("cannot create cfg.v");
printf ("Sheet: %s\n",$sheet->{Name});
foreach my $row (2..$sheet->{MaxRow}){
    if ($sheet->{Cells}[$row][0]->{Val} =~ /0x\w+/){
        $addr[$i] = $sheet->{Cells}[$row][0]->{Val};
        $register_name[$i] = $sheet->{Cells}[$row][1]->{Val};
        $addr[$i] =~ s/0x(\w+)/\U$1/ig;
        $addr_name[$i] = $register_name[$i] =~ s/(.+)/LP_ADDR_\U$1/igr;
        $i++;  
        $j=0;
    }elsif ($sheet->{Cells}[$row][0]->{Val} =~ /\[\d/){
        if ($sheet->{Cells}[$row][1]->{Val} =~ /reserve/i){
            ($field[$i-1][$j], $field_name[$i-1][$j])= ($sheet->{Cells}[$row][0]->{Val},$sheet->{Cells}[$row][1]->{Val});
            $property[$i-1][$j] = "none";
            $type[$i-1][$j] = "none";
        }else{
            ($field[$i-1][$j], $field_name[$i-1][$j], $property[$i-1][$j], $type[$i-1][$j])= ($sheet->{Cells}[$row][0]->{Val},$sheet->{Cells}[$row][1]->{Val},$sheet->{Cells}[$row][2]->{Val},$sheet->{Cells}[$row][3]->{Val});
        };

        $start[$i-1][$j] = $1 if $field[$i-1][$j] =~ /\[(\d+)/;
        $end[$i-1][$j] = $1 if $field[$i-1][$j] =~ /(\d+)\]/;
        $field_len[$i-1][$j] = $start[$i-1][$j]-$end[$i-1][$j]+1;

        $j++;  

    }else{
        next;
    };
};
$i--;
#################################################
##################################################
##################################################
##################################################
my $do = 1;
if ($do == 0){
}else{
##################################################
##################################################
##################################################
##################################################



# declaration of ports
print H "// declaration of ports\n";
for my $a (0..$i){
    for(0..$#{$field[$a]}){
        printf H "  output wire [%2s-1:0]             %-30s  ,\n",$field_len[$a][$_],$field_name[$a][$_] if $type[$a][$_] =~ /output/i;
        printf H "  input  wire [%2s-1:0]             %-30s  ,\n",$field_len[$a][$_],$field_name[$a][$_] if $type[$a][$_] =~ /input/i;
    };
};

#print @{$field_name[0]};

# declaration of registers' addresses
print H "// declaration of registers' addresses\n";
for(0..$i){
    printf H "localparam [C_ADDR_WIDTH-1:0]       %-30s = 16'h%s ;\n",$addr_name[$_],$addr[$_];
};

# declaration of int_registers
print H "// declaration of int_registers\n";
for my $a (0..$i){
    for(0..$#{$field[$a]}){
        printf H "reg  [%2s-1:0]                       int_%-30s;\n",$field_len[$a][$_],$field_name[$a][$_] if !($type[$a][$_] =~ /none/i);
    };
};

# declaration of output assignments
print H "// declaration of output assignments\n";
for my $a (0..$i){
    for(0..$#{$field[$a]}){
        printf H "assign %-30s = int_%-30s;\n",$field_name[$a][$_],$field_name[$a][$_] if $type[$a][$_] =~ /output/i;
    };
};

# declaration of input get
print H "// declaration of input get\n";
for my $a (0..$i){
    for(0..$#{$field[$a]}){
        printf H "always @ (posedge %s)\n",$clk if $type[$a][$_] =~ /input/i;
        printf H "  int_%-30s<= %s ;\n",$field_name[$a][$_],$field_name[$a][$_] if $type[$a][$_] =~ /input/i;
    };
};

# read
my @field_name_tmp;
print H "// code of read\n";
for my $a (0..$i){
    for(0..$#{$field[$a]}){
        $field_name_tmp[$a][$_] = $field_name[$a][$_] =~ s/(.+)/int_$1/r;
        if ($field_name[$a][$_] =~ /reserve/ig){
            $field_name_tmp[$a][$_] = $field_len[$a][$_]."'b0";
        };
    };
    my $temp = join "," ,reverse @{$field_name_tmp[$a]};    

    printf H "        %s: begin\n",$addr_name[$a];
    printf H "          rdata_r <= {%s};\n",$temp;
    printf H "        end\n";
};
# write
print H "// code of write\n";
for my $a (0..$i){
    for(0..$#{$field[$a]}){
        if ($property[$a][$_] =~ /W/) {
            printf H "// %s\n",$field_name[$a][$_];
            printf H "always @ (posedge %s) begin\n",$clk;
            printf H "  if (%s)\n",$rst;
            printf H "    int_%s <= 'd0;\n",$field_name[$a][$_];
            printf H "  else if (aclk_en) begin\n";
            printf H "    if (w_hs && waddr == %s)\n",$addr_name[$a];
            printf H "      int_%s <= (wdata%s & wmask%s) | (int_%s%s & ~wmask%s);\n",$field_name[$a][$_],$field[$a][$_],$field[$a][$_],$field_name[$a][$_],$field[$a][$_],$field[$a][$_];
            printf H "  end\n";
            printf H "end\n\n";
        };
    };
};


##################################################
##################################################
##################################################
##################################################

};

##################################################
##################################################
##################################################
##################################################
