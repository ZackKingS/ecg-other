//
//  ViewController.m
//  BLEMi
//
//  Created by jinkeke@techshino.com on 16/3/9.
//  Copyright © 2016年 www.techshino.com. All rights reserved.
//


#define MPDBluetoothScanResultKey @"peripheral"


#define BT_SD_READ_PACKET_SIZE 65
//from old src s
#define IMEC_BLE_MODE_SERVICE    0xFFD0
#define IMEC_BLE_MODE_ENABLER    0xFFD1


#define IMEC_BLE_BATTERY_SERVICE 0x180F
#define IMEC_BLE_BATTERY_LEVEL   0x2A19

#define IMEC_BLE_HR_SERVICE      0x180D
#define IMEC_BLE_HR_VALUE        0x2A37
#define IMEC_BLE_HR_VALUE2       0x2A38

#define IMEC_BLE_ECG_SERVICE     0xFFB0
#define IMEC_BLE_ECG_VALUE       0xFFB1


#define IMEC_BLE_ACC_SERVICE     0xFFA0
#define IMEC_BLE_ACC_VALUE       0xFFA3

#define IMEC_BLE_RES_SERVICE     0xFFC0
#define IMEC_BLE_RES_VALUE       0xFFC1

#define TI_KEYFOB_PROXIMITY_ALERT_UUID                      0x1802
#define TI_KEYFOB_PROXIMITY_ALERT_PROPERTY_UUID             0x2a06
#define TI_KEYFOB_PROXIMITY_ALERT_ON_VAL                    0x01
#define TI_KEYFOB_PROXIMITY_ALERT_OFF_VAL                   0x00
#define TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN                 1
#define TI_KEYFOB_PROXIMITY_TX_PWR_SERVICE_UUID             0x1804
#define TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_UUID        0x2A07
#define TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_READ_LEN    1

#define TI_KEYFOB_BATT_SERVICE_UUID                         0x180F
#define TI_KEYFOB_LEVEL_SERVICE_UUID                        0x2A19
#define TI_KEYFOB_LEVEL_SERVICE_READ_LEN                    1

#define TI_KEYFOB_ACCEL_SERVICE_UUID                        0xFFA0
#define TI_KEYFOB_ACCEL_ENABLER_UUID                        0xFFA1
#define TI_KEYFOB_ACCEL_RANGE_UUID                          0xFFA2
#define TI_KEYFOB_ACCEL_READ_LEN                            1
#define TI_KEYFOB_ACCEL_X_UUID                              0xFFA3
#define TI_KEYFOB_ACCEL_Y_UUID                              0xFFA4
#define TI_KEYFOB_ACCEL_Z_UUID                              0xFFA5

#define TI_KEYFOB_KEYS_SERVICE_UUID                         0xFFE0
#define TI_KEYFOB_KEYS_NOTIFICATION_UUID                    0xFFE1
#define TI_KEYFOB_KEYS_NOTIFICATION_READ_LEN                1

#import "ViewController.h"
#import "HiseeClassFormat.h"
#import "HiseeBtDeviceBP88A.h"
#import "HiseeBtDeviceRBP9804.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activeID;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UITextView *resultTextV;


@property (strong,nonatomic) CBCentralManager *centralManager;
@property (nonatomic) NSInteger isPacketStart;
@property (nonatomic) NSInteger packetLength;
@property (nonatomic) uint8_t previousData;
@property (nonatomic) NSMutableData *packetData;
@property (nonatomic) BOOL isFirstPacket;
@property NSArray* WEEKDAYS;
@property NSMutableArray* fileData;
@property (nonatomic) int HR;
@property (nonatomic) uint16_t ECG;
@property int firstAccx;
@property int firstAccy;
@property int firstAccz;
@property BOOL first;
@property (nonatomic) NSInteger bleCmdType;
@property (nonatomic) NSString *connectedDeviceUDID;
@property (nonatomic) BOOL connectDefault;
@property int currentCmd;
@property (nonatomic) BOOL reading;
@property (nonatomic) NSMutableArray *median;
@property (nonatomic) NSMutableDictionary *paramBuffer;


@property (weak, nonatomic) IBOutlet UILabel *heartLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryLabel;

@property (weak, nonatomic) IBOutlet UILabel *connectLabel;


@end

@implementation ViewController

-(void)reset
{
    self.packetLength = 0;
    self.isPacketStart = 0;
    self.previousData = 0;
    self.isFirstPacket = YES;
    self.packetData = [[NSMutableData alloc] initWithCapacity:BT_SD_READ_PACKET_SIZE];
    self.fileData = [[NSMutableArray alloc] init];
    self.first = NO;
    self.reading = NO;
    self.paramBuffer = [NSMutableDictionary dictionary];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self reset];
    
    theManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    self.connectBtn.enabled = NO;
}


//0.当前蓝牙主设备状态
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (central.state==CBCentralManagerStatePoweredOn) {
        self.title = @"0.蓝牙已就绪";
        self.connectBtn.enabled = YES;
    }else
    {
        self.title = @"蓝牙未准备好";
        [self.activeID stopAnimating];
        switch (central.state) {
            case CBCentralManagerStateUnknown:
                NSLog(@">>>CBCentralManagerStateUnknown");
                break;
            case CBCentralManagerStateResetting:
                NSLog(@">>>CBCentralManagerStateResetting");
                break;
            case CBCentralManagerStateUnsupported:
                NSLog(@">>>CBCentralManagerStateUnsupported");
                break;
            case CBCentralManagerStateUnauthorized:
                NSLog(@">>>CBCentralManagerStateUnauthorized");
                break;
            case CBCentralManagerStatePoweredOff:
                NSLog(@">>>CBCentralManagerStatePoweredOff");
                break;
            default:
                break;
        }
    }
}

//1.开始连接action
- (IBAction)startConnectAction:(id)sender {
    
    if (theManager.state==CBCentralManagerStatePoweredOn) {
        NSLog(@"1.主设备蓝牙状态正常，开始扫描外设...");
        self.title = @"扫描设备...";
        
        //扫描 Peripherals
        [theManager scanForPeripheralsWithServices:nil options:nil];
        
        //UI
        [self.activeID startAnimating];
        self.connectBtn.enabled = NO;
        self.resultTextV.text = @"";
    }
}

#pragma mark 设备扫描与连接的代理

//2.扫描设备  Peripheral
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"2.扫描连接外设：%@ %@",peripheral.name,RSSI);
    
    
     if ([peripheral.name hasPrefix:@"DV"]) {
        
        //保存 peripheral
        thePerpher = peripheral;
        
        //central 停止扫描
        [central stopScan];
        
        //central 连接 peripheral
        [central connectPeripheral:peripheral options:nil];
        
        
        self.title = @"发现蓝牙设备，开始连接...";
        self.resultTextV.text = [NSString stringWithFormat:@"2.发现手环：%@\n名称：%@\n",peripheral.identifier.UUIDString,peripheral.name];
    }
}

//3.连接到Peripherals-成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    self.title = @"3.连接成功，扫描信息...";
    NSLog(@"3.连接外设成功！%@",peripheral.name);
    
    //peripheral 设置代理
    [peripheral setDelegate:self];
    
    //peripheral 扫描服务
    [peripheral discoverServices:nil];
    NSLog(@"3.开始扫描外设服务 %@...",peripheral.name);
}


//4.扫描到服务 （Service） ,之后扫描特征 （Characteristics）
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error)
    {
        NSLog(@"4.扫描外设服务出错：%@-> %@", peripheral.name, [error localizedDescription]);
        self.title = @"find services error.";
        [self.activeID stopAnimating];
        self.connectBtn.enabled = YES;
        
        return;
    }
    NSLog(@"4.扫描到外设服务：%@ -> %@",peripheral.name,peripheral.services);
    
//    ECG
//    "<CBService: 0x283b8e080, isPrimary = YES, UUID = Battery>",
//    "<CBService: 0x283b8e000, isPrimary = YES, UUID = 26CC3FC0-6241-F5B4-5347-63A3097F6764>"
    
    for (CBService *service in peripheral.services) {
        
        //peripheral 扫描外设 service 的 Characteristics
        [peripheral discoverCharacteristics:nil forService:service];
    }
    NSLog(@"4.开始扫描外设服务的特征 %@...",peripheral.name);
}


//5.扫描到了特征 （Characteristics） ,根据 UUID 处理特征（Characteristics）
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error)
    {
        NSLog(@"5.扫描外设的特征失败！%@->%@-> %@",peripheral.name,service.UUID, [error localizedDescription]);
        self.title = @"find characteristics error.";
        [self.activeID stopAnimating];
        self.connectBtn.enabled = YES;
        return;
    }
    
    NSLog(@"5.扫描到外设服务特征有：%@->%@->%@",peripheral.name,service.UUID,service.characteristics);
    
    //ECG
//    "<CBCharacteristic: 0x281e63cc0, UUID = BF8796F1-64F7-70B5-1E41-09BB46D79100, properties = 0x1A, value = <>, notifying = NO>",
//    "<CBCharacteristic: 0x281e63c00, UUID = BF8796F1-64F7-70B5-1E41-09BB46D79101, properties = 0xA, value = <>, notifying = NO>",
//    "<CBCharacteristic: 0x281e63c60, UUID = BF8796F1-64F7-70B5-1E41-09BB46D79102, properties = 0xA, value = <>, notifying = NO>",
//    "<CBCharacteristic: 0x281e63d20, UUID = BF8796F1-64F7-70B5-1E41-09BB46D79103, properties = 0xA, value = <>, notifying = NO>"
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ((characteristic.properties & CBCharacteristicPropertyNotify) > 0) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];//订阅
            
            NSString* charUUID = [NSString stringWithFormat:@"%@", characteristic.UUID];
             if ([charUUID isEqualToString:@"BF8796F1-64F7-70B5-1E41-09BB46D79100"]) {
                 NSString *cmd = @"S VIEW ALL ON \r\n";
                 NSData *data = [cmd dataUsingEncoding:NSASCIIStringEncoding];
                 [thePerpher writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            }
        }
    }
}



#pragma mark 设备信息处理
//6.设备信息处理
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if (error) {
        NSLog(@"扫描外设的特征失败！%@-> %@",peripheral.name, [error localizedDescription]);
        self.title = @"find value error.";
        return;
    }

    
    //原始数据  不完整的包
//    NSData *data = characteristic.value;
//
//    NSLog(@"--data--%@",data);
    
    [self dealWithDVData:characteristic];
    
    [self.activeID stopAnimating];
    self.connectBtn.enabled = YES;
    self.title = @"6.信息扫描完成";
}

-(UInt16) CBUUIDToInt:(CBUUID *) UUID {
    char b1[16];
    [UUID.data getBytes:b1 length:sizeof(b1)];
    return ((b1[0] << 8) | b1[1]);
}

-(void)dealWithDVData:(CBCharacteristic *)characteristic{
    
    UInt16 characteristicUUID = [self CBUUIDToInt:characteristic.UUID];
    int i = 0;
    NSUInteger receiveLength = [characteristic.value length];
    switch(characteristicUUID){
        case IMEC_BLE_BATTERY_LEVEL:
        {
            const char *data = (const char *)[characteristic.value bytes];
            
//            NSLog(@"data : %@",characteristic.value);
            
            for (i =0; i<receiveLength ;i++)
            {
            
                if (data[i] == 0x53 && self.isPacketStart == 0) {
                    if (self.previousData == 0x50 || self.isFirstPacket)
                    {
                        self.isFirstPacket = NO;
                        self.isPacketStart = 1;
                        self.packetData =[[NSMutableData alloc]initWithCapacity:BT_SD_READ_PACKET_SIZE];
                    }
                    else
                    {
                        self.isPacketStart = 0;
                        NSLog(@"bad packet");
                    }
                }
                else if (data[i] != 0x50 && self.isPacketStart == 2 && [self.packetData length] == self.packetLength + 1){
                    NSLog(NSLocalizedString(@"协议错误",nil));
                    self.isPacketStart = 0;
                }
                else if (data[i] == 0x50 && self.isPacketStart == 2 && [self.packetData length] == self.packetLength + 1){
                    self.isPacketStart = 0;
                    static uint8_t payLoad0[BT_SD_READ_PACKET_SIZE];
                    int j =1;
                    [self.packetData getBytes:payLoad0 length:BT_SD_READ_PACKET_SIZE];
                    if (payLoad0[0] == 0x00) {
                        // ECG packet
                        NSMutableArray *arr = [NSMutableArray array];
                        for (j = 1;j < _packetLength; j += 2)
                        {
                            UInt16 ecg = ((char)(payLoad0[j]) << 8) +payLoad0[j+1];
                            self.ECG = ecg;
                            [arr addObject:@(ecg)];
                            //                            if([self.delegate respondsToSelector:@selector(ecgValuesUpdated:)])
                            //                            {
                            //                                [[self delegate] ecgValuesUpdated:self.ECG];
                            //                            }
                        }
//                        if([self.delegate respondsToSelector:@selector(ecgValuesUpdated:)])
//                        {
//                            [[self delegate] ecgValuesUpdated:arr];
//                        }
                    }
                    else if (payLoad0[0] == 0x02) {
                        // ACC packet
                        for (j = 1;j < 24; j += 6)
                        {
                            int16_t accx = 0;
                            accx |= (payLoad0[j+1]<<8);
                            accx |= payLoad0[j];
                            
                            int16_t accy= 0;
                            accy |= (payLoad0[j+3]<<8);
                            accy |= payLoad0[j+2];
                            
                            int16_t accz = 0;
                            accz |= (payLoad0[j+5]<<8);
                            accz |= payLoad0[j+4];
                            if (self.first == NO) {
                                self.first = YES;
                                self.firstAccx = accx;
                                self.firstAccy = accy;
                                self.firstAccz = accz;
                            }
//                            if([self.delegate respondsToSelector:@selector(accValuesUpdated:y:z:)])
//                            {
//                                [[self delegate] accValuesUpdated:self.firstAccx-accx y:accy-self.firstAccy z:accz-self.firstAccz];
//                            }
                        }
                    }
                    else if(payLoad0[0] == 0x05){
                        // Heart packet
                        UInt16 hr = payLoad0[1]+payLoad0[2]*256;
                        
//                        NSLog(@"Heart-------%d",hr);
                        
                        self.heartLabel.text = [NSString stringWithFormat:@"心跳: %d",hr];
                        
                        self.HR = hr;
//                        if([self.delegate respondsToSelector:@selector(hrValuesUpdated:)])
//                        {
//                            [[self delegate] hrValuesUpdated:self.HR];
//                        }
                    }
                    else if(payLoad0[0] == 0x0B ){
                        // Battery
                        UInt16 battery = payLoad0[1]+payLoad0[2]*256;
                        
//                        NSLog(@"battery-------%d",battery);
                        
                        self.batteryLabel.text = [NSString stringWithFormat:@"电量: %d",battery];
                        
                        //
                        //                        self.batteryLevel = battery;
//                        if([self.delegate respondsToSelector:@selector(batteryValuesUpdated:)])
//                        {
//                            [[self delegate] batteryValuesUpdated:battery];
//                        }
                    }else if(payLoad0[0] == 0x0F ){
                        // Connection
                        UInt16 connection = payLoad0[1]+payLoad0[2]*256;
                        
//                        NSLog(@"connection-------%d",connection);
                        
                        self.connectLabel.text = [NSString stringWithFormat:@"连接状态: %d",connection];
//                        if([self.delegate respondsToSelector:@selector(connectionValuesUpdated:)])
//                        {
//                            [[self delegate] connectionValuesUpdated:connection];
//                        }
                    }
                }
                
                else if ([self.packetData length] == self.packetLength + 1 && self.isPacketStart == 3){
                    if(data[i] == 0x50)
                    {
                        self.isPacketStart = 0;
                        //NSLog(@"parse packet %@",self.packetData);
                        static uint8_t payLoad[BT_SD_READ_PACKET_SIZE];
                        
                        [self.packetData getBytes:payLoad length:BT_SD_READ_PACKET_SIZE];
                        
                        switch (payLoad[0])
                        {
                                
                                //-- Status
                            case 0x0D:{
                                
                                NSString *value = [[NSString alloc] initWithData:self.packetData encoding:NSUTF8StringEncoding];
                                NSArray *arr = [value componentsSeparatedByString:@" "];
                                if(value && [value containsString:@"SDREC_"])
                                {
//                                    if([self.delegate respondsToSelector:@selector(statusUpdated:left:)])
//                                    {
//                                        if([arr[0] containsString:@"SDREC_ON"])
//                                        {
//                                            [[self delegate] statusUpdated:@"ON" left:[arr[1] integerValue]];
//                                        }
//                                        else if([arr[0] containsString:@"SDREC_OFF"])
//                                        {
//                                            [[self delegate] statusUpdated:@"OFF" left:0];
//                                        }
//                                        else
//                                        {
//                                            [[self delegate] statusUpdated:@"ERR" left:0];
//                                        }
//                                        break;
//                                    }
                                }
                                else if( value && [value containsString:@"SDR_"])
                                {
                                    if([value containsString:@"SDR_ON"])
                                    {
//                                        if(self.bleCmdType != MPDeviceCmdTypeTypeSDTXOn && self.bleCmdType != MPDeviceCmdTypeNone)
//                                        {
//                                            switch (self.bleCmdType) {
//                                                case MPDeviceCmdTypeTypeSDListFile:
//                                                    [self listSDFile];
//                                                    break;
//                                                case MPDeviceCmdTypeTypeSDListMark:
//                                                    [self readMarkList];
//                                                    break;
//                                                case MPDeviceCmdTypeTypeSDMarkEcg:
//                                                    [self readMarkEcg:[[self.paramBuffer objectForKey:@"MarkIndex"] integerValue]];
//                                                    break;
//                                                case MPDeviceCmdTypeTypeSDFormat:
//                                                    [self formatSDCard];
//                                                    break;
//                                                default:
//                                                    break;
//                                            }
//                                        }
                                    }
                                    else
                                    {
//                                        if(self.bleCmdType != MPDeviceCmdTypeTypeSDSDTXOff && self.bleCmdType != MPDeviceCmdTypeNone)
//                                        {
//                                            switch (self.bleCmdType) {
//                                                case MPDeviceCmdTypeTypeSDListFile:
//                                                    [self listSDFile];
//                                                    break;
//                                                case MPDeviceCmdTypeTypeSDListMark:
//                                                    [self readMarkList];
//                                                    break;
//                                                case MPDeviceCmdTypeTypeSDMarkEcg:
//                                                    [self readMarkEcg:[[self.paramBuffer objectForKey:@"MarkIndex"] integerValue]];
//                                                    break;
//                                                case MPDeviceCmdTypeTypeSDFormat:
//                                                    [self formatSDCard];
//                                                    break;
//                                                default:
//                                                    break;
//                                            }
//                                        }
                                        
                                    }
                                }
                                else if([value containsString:@"WRONG_COMMAND"])
                                {
//                                    switch (self.bleCmdType) {
//                                        case MPDeviceCmdTypeTypeSDRecordState:
//                                            if([self.delegate respondsToSelector:@selector(statusUpdated:left:)])
//                                            {
//                                                [[self delegate] statusUpdated:@"ERR" left:0];
//                                            }
//                                            break;
//                                        case MPDeviceCmdTypeTypeSDFormat:
//                                            [self formatSDCard];
//                                            break;
//                                        default:
//                                            if((self.bleCmdType != MPDeviceCmdTypeTypeSDTXOn || self.bleCmdType != MPDeviceCmdTypeTypeSDSDTXOff
//                                                ) && self.bleCmdType != MPDeviceCmdTypeNone)
//                                            {
//                                                switch (self.bleCmdType) {
//                                                    case MPDeviceCmdTypeTypeSDListFile:
//                                                        [self listSDFile];
//                                                        break;
//                                                    case MPDeviceCmdTypeTypeSDListMark:
//                                                        [self readMarkList];
//                                                        break;
//                                                    case MPDeviceCmdTypeTypeSDMarkEcg:
//                                                        [self readMarkEcg:[[self.paramBuffer objectForKey:@"MarkIndex"] integerValue]];
//                                                        break;
//
//                                                    default:
//                                                        break;
//                                                }
//                                            }
//                                            break;
//                                    }
                                }
                                else if([value containsString:@"FORMATING"])
                                {
                                    NSLog(@"FORMATTING");
                                }
                            }
                                break;
                                //-- File : start
                            case 0x03:{
                                NSLog(@"%@",@"File - start!");
                                break;}
                                //-- File : end
                            case 0x04:{
                                NSLog(@"%@",@"File - end!");
#ifdef NewFunc2Hour
//                                if([self.delegate respondsToSelector:@selector(fileUpdated:type:)])
//                                {
//                                    MPFileType type = MPFileTypeNone;
//                                    if(self.bleCmdType == MPDeviceCmdTypeTypeSDListFile)
//                                    {
//                                        type = MPFileTypeIndexFile;
//                                    }
//                                    else
//                                    {
//                                        type = MPFileTypeMarkFile;
//                                    }
//                                    [[self delegate] fileUpdated:[self.fileData copy] type:type];
//                                }
//                                else if([self.delegate respondsToSelector:@selector(fileUpdated:)])
//                                {
//                                    [[self delegate] fileUpdated:[self.fileData copy]];
//                                }
#else
//                                if([self.delegate respondsToSelector:@selector(fileUpdated:)])
//                                {
//                                    [[self delegate] fileUpdated:[self.fileData copy]];
//                                }
#endif
                                [_fileData removeAllObjects];
                                break;}
                                //-- File : data
                            case 0x0E:{
                                NSLog(@"%@",@"File - data!");
                                
                                for (int k = 1; k <= self.packetLength; ++k)
                                {
                                    [self.fileData addObject:[NSNumber numberWithUnsignedChar:payLoad[k]]];
                                }
                                break;}
                            case 0x07:
                            {
                                NSLog(@"%@",@"Mark File - data!");
                                
                                for (int k = 1; k <= self.packetLength; ++k)
                                {
                                    [self.fileData addObject:[NSNumber numberWithUnsignedChar:payLoad[k]]];
                                }
                            }
                                //--
                            default:{
                                break;}
                        }
                        
                    }
                    else
                    {
                        self.isPacketStart = 0;
                        //                        self.badPacketNumber++;
                    }
                }
                
                else if(self.isPacketStart == 1){
                    self.isPacketStart = 2;
                    self.packetLength = data[i];
                }
                //                else if(self.isPacketStart == 2){
                //                    [self.packetData appendData:[NSData dataWithBytes:&data[i] length:1]];
                //                }
                else if(self.isPacketStart == 2){
                    static uint8_t payLoad1[BT_SD_READ_PACKET_SIZE];
                    [self.packetData getBytes:payLoad1 length:BT_SD_READ_PACKET_SIZE];
                    if(payLoad1[0] == 0x0E || payLoad1[0] == 0x03 || payLoad1[0] == 0x04 || payLoad1[0] == 0x0D || payLoad1[0] == 0x07)
                    {
//                        if(self.bleCmdType == MPDeviceCmdTypeTypeSDListFile ||
//                           self.bleCmdType == MPDeviceCmdTypeTypeSDRecordOff ||
//                           self.bleCmdType == MPDeviceCmdTypeTypeSDRecordOn ||
//                           self.bleCmdType == MPDeviceCmdTypeTypeSDRecordState ||
//                           self.bleCmdType == MPDeviceCmdTypeTypeSDListMark ||
//                           self.bleCmdType == MPDeviceCmdTypeTypeSDMarkEcg ||
//                           self.bleCmdType == MPDeviceCmdTypeTypeSDFormat)
//                        {
//                            self.isPacketStart = 3;
//                        }
                        [self.packetData appendData:[NSData dataWithBytes:&data[i] length:1]];
                    }
                    else
                    {
                        [self.packetData appendData:[NSData dataWithBytes:&data[i] length:1]];
                    }
                }
                
                else if(self.isPacketStart == 3){
                    [self.packetData appendData:[NSData dataWithBytes:&data[i] length:1]];
                }
                else
                {
                    self.isPacketStart = 0;
                    NSLog(@"bad packet");
                }
                self.previousData = data[i];
                //                NSLog(@"[self.packetData length]:%ld",[self.packetData length]);
                //                NSLog(@"self.packetLength:%ld",self.packetLength);
                //                NSLog(@"self.isPacketStart:%ld",self.isPacketStart);
            }
        }
            break;
            /*
             case IMEC_BLE_RES_VALUE:
             {
             
             NSUInteger resDataLength = [characteristic.value length];
             
             const uint8_t *resData = [characteristic.value bytes];
             
             for (int i = 0 ; i< resDataLength ; i+=2)
             {
             
             
             uint16_t ResValue = ( (resData[i] << 8 ) + resData[i+1] );
             
             // NSLog(@"%@%hu",@"from parse :", ResValue);
             self.RES = ResValue;
             [[self delegate] resValuesUpdated:self.RES];
             
             
             
             }
             
             
             
             break;
             }
             
             
             
             case IMEC_BLE_BATTERY_LEVEL:
             {
             char batlevel;
             [characteristic.value getBytes:&batlevel length:1];
             self.batteryLevel = (float)batlevel;
             [[self delegate] batteryValuesUpdated:self.batteryLevel];
             
             break;
             
             }
             
             case IMEC_BLE_HR_VALUE:
             {
             NSData *array = [characteristic value];
             //                 NSString *dataString = @"";
             //                 NSString *dataStringBaseLine = @"";
             int i;
             unsigned char *data;
             data = (unsigned char*)malloc([array length]);
             [array getBytes:data length:[array length]];
             for (i =1; i<16; i+=2) {
             UInt16 ecg = data[i]+(data[i+1]*256);
             //                     dataString = [dataString stringByAppendingFormat:@"%d ",ecg];
             //                     float fecg = (((float)ecg * 1.05 *1000)/(4095*ECG_GAIN));
             //                     if(self.isShow == YES)
             //                     {
             //                         fecg = baselineRemove(fecg);
             //                         [self showECG:fecg];
             //                         [self medianFilterAndHeartRate:ecg];
             //                     }
             //                     int fecgADC= ((fecg*4095*ECG_GAIN)/1050);
             //                     dataStringBaseLine = [dataStringBaseLine stringByAppendingFormat:@"%d ",fecgADC];
             
             [self.median addObject:[NSNumber numberWithInt:ecg]];
             if ([self.median count]>=73)
             {
             [self.median removeObjectAtIndex:0];
             NSArray *sorted = [self.median sortedArrayUsingSelector:@selector(compare:)];    // Sort the array by value
             NSUInteger middle = [sorted count] / 2;                                           // Find the index of the middle element
             NSNumber *median = [sorted objectAtIndex:middle];
             
             int hr = cwt_qrs(ecg-[median intValue]);
             if(hr!= IMPOSSIBLE_HR)
             {
             self.HR = hr;
             [[self delegate] hrValuesUpdated:self.HR];
             }
             }
             
             self.ECG = ecg;
             if([self.delegate respondsToSelector:@selector(ecgValuesUpdated:)])
             {
             [[self delegate] ecgValuesUpdated:self.ECG];
             }
             }
             
             //                 NSUInteger battery;
             //                 battery = data[i];
             
             
             //                 [self.labelHR setText:[NSString stringWithFormat:@"HR:%ld Battery:%ld",self.heartRate,self.battery]];
             
             
             //
             //             const uint8_t *hrData = [characteristic.value bytes];
             //
             //             self.HR = (int)hrData[1];
             //
             //
             //
             //             [[self delegate] hrValuesUpdated:self.HR];
             
             break;
             
             }
             
             case IMEC_BLE_ECG_VALUE:
             {
             
             
             NSUInteger ecgDataLength = [characteristic.value length];
             
             const uint8_t *ecgData = [characteristic.value bytes];
             
             
             
             
             
             for (int i = 0 ; i< ecgDataLength ; i+=2)
             {
             
             
             
             
             uint16_t ECGValue = ( ((0x0F & ecgData[i]) << 8 ) + ecgData[i+1] );
             
             
             
             self.ECG = ECGValue;
             [[self delegate] ecgValuesUpdated:self.ECG];
             
             
             }
             
             
             break;
             }
             
             
             case IMEC_BLE_ACC_VALUE:
             {
             
             
             
             const int8_t *accData = [characteristic.value bytes];
             
             NSMutableArray *AccArray = [[NSMutableArray alloc]init];
             
             for (int i =0 ; i < 18; i+=2)
             {
             
             
             
             uint8_t accMSB = accData[i];
             uint8_t accLSB = accData[i+1];
             
             
             
             int16_t accValue = (int16_t)(accLSB + [self accDataParse:accMSB]);
             
             
             
             [AccArray addObject:[NSNumber numberWithInt:accValue]];
             
             
             
             
             
             
             
             }
             
             for(int j = 0 ; j<9 ; j+=3)
             {
             
             [[self delegate] accValuesUpdated:[[AccArray objectAtIndex:j] integerValue] y:[[AccArray objectAtIndex:j+1] integerValue] z:[[AccArray objectAtIndex:j+2] integerValue]];
             
             }
             
             
             
             
             
             
             
             
             
             
             break;
             }
             
             
             
             case TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_UUID:
             {
             char TXLevel;
             [characteristic.value getBytes:&TXLevel length:TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_READ_LEN];
             self.TXPwrLevel = TXLevel;
             [[self delegate] TXPwrLevelUpdated:TXLevel];
             }
             */
        default:
            break;
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"写入错误 = %@, 写入特征uuid = %@", error, characteristic.UUID);
    } else {
        NSLog(@"特征值 = %@, 写入成功", characteristic.UUID);
    }
}


//连接外设失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"连接到外设 失败！%@ %@",[peripheral name],[error localizedDescription]);
    [self.activeID stopAnimating];
    self.title = @"连接失败";
    self.connectBtn.enabled = YES;
}

//与外设断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"与外设备断开连接 %@: %@", [peripheral name], [error localizedDescription]);
    self.title = @"连接已断开";
    self.connectBtn.enabled = YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)stopShakeAction:(id)sender {
    
}

//震动
- (IBAction)shakeBankAction:(id)sender {
    
}

//断开连接Action
- (IBAction)disConnectAction:(id)sender {
    if(thePerpher)
    {
        [theManager cancelPeripheralConnection:thePerpher];
        thePerpher = nil;
        theSakeCC = nil;
        self.title = @"设备连接已断开";
    }
}

- (void)disConnectBt
{
    thePerpher = nil;
    
}


@end
