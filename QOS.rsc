# variables
# define local Variables
global SPEED;
global USER;
set $USER "flanagan"
#Clients Line Speed
set $SPEED "10M";

/system identity
set name=$USER

/interface pppoe-client
set [ find name=pppoe-out1 ] name=("pppoe_out_".$USER);

/ip firewall layer7-protocol
add name=speedtest regexp="^.+(speedtest).*\\\$"

/ip firewall mangle
add action=mark-connection chain=prerouting comment=DSCP_46_Critical dscp=46 \
    new-connection-mark=Critical
add action=mark-connection chain=prerouting comment=\
    Protocol_WinBox_Flash_Override new-connection-mark=Flash_Override port=8291 \
    protocol=tcp
add action=mark-connection chain=prerouting comment=\
    Protocol_ICMP_Flash_Override new-connection-mark=Flash_Override protocol=\
    icmp
add action=mark-connection chain=prerouting comment=Protocol_DNS_Flash_Override \
    new-connection-mark=Flash_Override port=53 protocol=udp
add action=mark-connection chain=prerouting comment=DSCP_26_Flash dscp=26 \
    new-connection-mark=Flash
add action=mark-connection chain=prerouting comment=DSCP_24_Flash dscp=24 \
    new-connection-mark=Flash
add action=mark-connection chain=prerouting comment=PORT_5060_Flash \
    new-connection-mark=Flash port=5060 protocol=udp
add action=mark-connection chain=forward comment=Protocol_SpeedTest_Immediate \
    layer7-protocol=speedtest new-connection-mark=Immediate
add action=mark-connection chain=prerouting new-connection-mark=Immediate \
    protocol=tcp src-port=8080
add action=mark-connection chain=postrouting dst-port=8080 new-connection-mark=\
    Immediate protocol=tcp
add action=mark-connection chain=prerouting comment=Protocol_HTTP_Immediate \
    new-connection-mark=Immediate packet-size=0-3000 port=80 protocol=tcp
add action=mark-connection chain=prerouting comment=Protocol_HTTPS_Immediate \
    new-connection-mark=Immediate packet-size=0-3000 port=443 protocol=tcp
add action=mark-connection chain=prerouting comment=Protocol_HTTP_Best_Effort \
    new-connection-mark=Best_Effort packet-size=!0-3000 port=80 protocol=tcp
add action=mark-connection chain=prerouting comment=Protocol_HTTPS_Best_Effort \
    new-connection-mark=Best_Effort packet-size=0-3000 port=443 protocol=tcp
add action=mark-connection chain=prerouting comment=Protocol_P2P_Least_Effort \
    connection-mark=Least_Effort new-connection-mark=Least_Effort p2p=all-p2p \
    packet-size=0-3000
add action=mark-connection chain=prerouting comment=\
    "Other_Best_Effort(Keep Bellow Least_Effort)" connection-mark=no-mark \
    new-connection-mark=Best_Effort packet-size=0-3000
add action=mark-packet chain=prerouting comment=Mark_Packet_Critical \
    connection-mark=Critical new-packet-mark=Critical passthrough=no
add action=mark-packet chain=prerouting comment=Mark_Packet_Flash \
    connection-mark=Flash new-packet-mark=Flash passthrough=no
add action=mark-packet chain=prerouting comment=Mark_Packet_Flash_Override \
    connection-mark=Flash_Override new-packet-mark=Flash_Override passthrough=\
    no
add action=mark-packet chain=prerouting comment=Mark_Packet_Immediate \
    connection-mark=Immediate new-packet-mark=Immediate passthrough=no
add action=mark-packet chain=prerouting comment=Mark_Packet_Best_Effort \
    connection-mark=Best_Effort new-packet-mark=Best_Effort passthrough=no
add action=mark-packet chain=prerouting comment=Mark_Packet_Least_Effort \
    connection-mark=Least_Effort new-packet-mark=Least_Effort passthrough=no

/queue tree
add max-limit=$SPEED name=PCQ_DOWN parent=global queue=PCQ_download
add max-limit=$SPEED name=PCQ_UP parent=("pppoe_out_".$USER) queue=PCQ_upload
add name=Critical_Down packet-mark=Critical parent=PCQ_DOWN priority=1 queue=\
    default
add name=Flash_Override_Down packet-mark=Flash_Override parent=PCQ_DOWN \
    priority=2 queue=default
add name=Flash_Down packet-mark=Flash parent=PCQ_DOWN priority=3 queue=default
add name=Immediate_Down packet-mark=Immediate parent=PCQ_DOWN priority=4 queue=\
    default
add name=Priority_Down packet-mark=Priority parent=PCQ_DOWN priority=5 queue=\
    default
add name=Least_Effort_DOWN packet-mark=Least_Effort parent=PCQ_DOWN priority=7 \
    queue=default
add name=Critical_UP packet-mark=Critical parent=PCQ_UP priority=1 queue=\
    default
add name=Flash_Override_UP packet-mark=Flash_Override parent=PCQ_UP priority=2 \
    queue=default
add name=Flash_Up packet-mark=Flash parent=PCQ_UP priority=3 queue=default
add name=Immediate_UP packet-mark=Immediate parent=PCQ_UP priority=4 queue=\
    default
add name=Priority_UP packet-mark=Priority parent=PCQ_UP priority=5 queue=\
    default
add name=Least_Effort_UP packet-mark=Least_Effort parent=PCQ_UP priority=7 \
    queue=default
add name=Best_Effort_Down packet-mark=Best_Effort parent=PCQ_DOWN priority=6 \
    queue=default
add name=Best_Effort_UP packet-mark=Best_Effort parent=PCQ_UP priority=6 queue=\
    default

/ip firewall service-port
set h323 disabled=yes
set sip disabled=yes
