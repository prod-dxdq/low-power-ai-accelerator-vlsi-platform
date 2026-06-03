set signals [list \
    {tb_traffic_light_controller.clk} \
    {tb_traffic_light_controller.rst} \
    {tb_traffic_light_controller.green} \
    {tb_traffic_light_controller.yellow} \
    {tb_traffic_light_controller.red} \
    {tb_traffic_light_controller.uut.state[1:0]} \
    {tb_traffic_light_controller.uut.state_count[1:0]}]

gtkwave::addSignalsFromList $signals
gtkwave::setMarker 0
gtkwave::setZoomRangeTimes 0 [gtkwave::getMaxTime]
gtkwave::presentWindow