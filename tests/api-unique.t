use Test::More tests => 10;
use Cwd;
use URI::Escape;
use MolochTest;
use Test::Differences;
use strict;


sub get {
my ($param) = @_;

    my $txt = $MolochTest::userAgent->get("http://$MolochTest::host:8123/unique.txt?$param")->content;
    my @lines = split(/\n/, $txt);

    # Sort since the server returns any order with the same counts
    @lines = sort @lines;
    return join("\n", @lines) . "\n";
}

my $pwd = getcwd() . "/pcap";
my $files = uri_escape("(file=$pwd/socks-http-example.pcap||file=$pwd/socks-http-pass.pcap||file=$pwd/socks-https-example.pcap||file=$pwd/socks5-http-302.pcap||file=$pwd/socks5-rdp.pcap||file=$pwd/socks5-reverse.pcap||file=$pwd/socks5-smtp-503.pcap)");



my $txt = get("");
is ($txt, "Missing field parameter\n", "unique.txt no field parameter");


$txt = get("date=-1&field=no");
eq_or_diff($txt, "test\n", "Nodes", { context => 3 });

$txt = get("date=-1&field=no&expression=$files&counts=1");
eq_or_diff($txt, "test, 13\n", "Nodes count", { context => 3 });

$txt = get("date=-1&field=a1&expression=$files&counts=1");
eq_or_diff($txt, 
"10.0.0.1, 2
10.0.0.2, 1
10.0.0.3, 1
10.180.156.185, 9
", "ip count", { context => 3 });

$txt = get("date=-1&field=ta&expression=$files&counts=1");
eq_or_diff($txt, 
"byhost2, 7
byip1, 1
domainwise, 7
dstip, 4
hosttaggertest1, 7
hosttaggertest2, 7
http:content:application/x-gzip, 1
http:content:text/html, 6
http:method:GET, 6
http:statuscode:200, 5
http:statuscode:302, 2
iptaggertest1, 1
iptaggertest2, 1
ipwise, 1
ipwisecsv, 4
node:test, 13
protocol:http, 6
protocol:rdp, 1
protocol:smtp, 1
protocol:socks, 12
protocol:tls, 3
smtp:authlogin, 1
socks:password, 2
srcip, 4
tcp, 13
wisebyhost2, 7
wisebyip1, 1
", "tags count", { context => 3 });

$txt = get("date=-1&field=hh1&expression=$files&counts=1");
eq_or_diff($txt, 
"accept, 6
accept-encoding, 2
accept-language, 1
connection, 1
cookie, 2
host, 6
referer, 1
user-agent, 6
", "http header count", { context => 3 });

$txt = get("date=-1&field=hmd5&expression=$files");
eq_or_diff($txt,
"09b9c392dc1f6e914cea287cb6be34b0
2069181ae704855f29caf964ca52ec49
222315d36e1313774cb1c2f0eb06864f
b0cecae354b9eab1f04f70e46a612cb1
", "http md5", { context => 3 });

$txt = get("date=-1&field=hmd5&expression=$files&counts=1");
eq_or_diff($txt,
"09b9c392dc1f6e914cea287cb6be34b0, 4
2069181ae704855f29caf964ca52ec49, 1
222315d36e1313774cb1c2f0eb06864f, 1
b0cecae354b9eab1f04f70e46a612cb1, 1
", "http md5 count", { context => 3 });

$txt = get("date=-1&field=rawus&expression=$files&counts=0");
eq_or_diff($txt,
"//www.example.com/
//www.google.com/
//www.google.com/search?client=firefox&rls=en&q=sheepskin%20boots&start=0&num=10&hl=en&gl=us&uule=xxxxxxxxxxxxxxxxxxxxxxxxxxxx
//www.google.com/search?client=firefox&rls=en&q=sheepskin%20boots&start=10&num=10&hl=en&gl=us&uule=xxxxxxxxxxxxxxxxxxxxxxxxxxxx
", "http uri", { context => 3 });

$txt = get("date=-1&field=rawus&expression=$files&counts=1");
eq_or_diff($txt,
"//www.example.com/, 4
//www.google.com/, 1
//www.google.com/search?client=firefox&rls=en&q=sheepskin%20boots&start=0&num=10&hl=en&gl=us&uule=xxxxxxxxxxxxxxxxxxxxxxxxxxxx, 1
//www.google.com/search?client=firefox&rls=en&q=sheepskin%20boots&start=10&num=10&hl=en&gl=us&uule=xxxxxxxxxxxxxxxxxxxxxxxxxxxx, 1
", "http uri", { context => 3 });
