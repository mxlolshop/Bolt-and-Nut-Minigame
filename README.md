+ How to use (EVENT)
+ Move ui right or left, in percentage, 50% middle of the screen, without the % symbol
x = 50

+ Move ui top or bottom, in percentage, 50% middle of the screen, without the % symbol
y = 50

+ Speed ​​bolt, 1.0 normal, 0.5 slower, 1.5 faster, enter whatever value you want
+ Depending on the speed, it will make the minigame more difficult
speed = 1.0

+ Nut position, creating difficulties. 1 to 4
+ 4 is the furthest, therefore more difficult.
position = 2

+ callback = Defines whether the minigame succeeded or failed
    'SUCCESS' or 'FAILED'

+ Event usage example Five M Script
TriggerEvent("mxStartBoltGame", x, y, speed, position, function(callback)
    if callback == 'SUCCESS' then
        print(">> Bolt Game [ SUCCESS ]")
    elseif callback == 'FAILED' then
        print(">> Bolt Game [ FAILED ]")
    end
end)
