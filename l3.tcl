set ns [new Simulator]
set tf [open l3.tr w]
$ns trace-all $tf

set nf [open l3.nam w]
$ns namtrace-all $nf
set cwind [open win.tr w]
$ns rtproto DV

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

$ns duplex-link $n0 $n1 1Mb 5ms DropTail
$ns duplex-link $n0 $n2 1Mb 5ms DropTail
$ns duplex-link $n1 $n2 1Mb 5ms DropTail
$ns duplex-link $n1 $n4 1Mb 5ms DropTail
$ns duplex-link $n2 $n3 1Mb 5ms DropTail
$ns duplex-link $n3 $n4 1Mb 5ms DropTail
$ns duplex-link $n4 $n5 1Mb 5ms DropTail
$ns duplex-link $n3 $n5 1Mb 5ms DropTail

$ns duplex-link-op $n1 $n2 orient down
$ns duplex-link-op $n1 $n4 orient right
$ns duplex-link-op $n4 $n3 orient down
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n0 $n1 orient right-up
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n4 $n5 orient right-down
$ns duplex-link-op $n3 $n5 orient right-up

set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0

set tcp1 [new Agent/TCPSink]
$ns attach-agent $n4 $tcp1
$ns connect $tcp0 $tcp1

set ftp [new Application/FTP]

$ftp attach-agent $tcp0

$ns rtmodel-at 1.0 down $n1 $n4
$ns rtmodel-at 3.0 up $n1 $n4

$ns at 0.2 "$ftp start"
$ns at 4.0 "$ftp stop"

proc plotWindow {tcpSource file} {
	global ns
	set time 0.01
	set now [$ns now]
	set cwnd [$tcpSource set cwnd_]
	puts $file "$now $cwnd"
	$ns at [expr $now+$time] "plotWindow $tcpSource $file"}
$ns at 1.0 "plotWindow $tcp0 $cwind"

proc finish {} {
global ns tf nf
$ns flush-trace
close $tf 
close $nf
exec nam l3.nam &
exit 0
}
$ns at 5.0 "finish"
$ns run
 
