////
////  MPDBluetoothManager.m
////  MicroPort
////
////  Created by FNST on 15/12/15.
////
////
//#include <stdlib.h>
//#include "cwt.h"
//
//#import "UUProgressHUD.h"
//#import "MPDBluetoothManager.h"
//#import <UIImageView+WebCache.h>
//#import "MPPConstants.h"
//#import "MPSDFileModel.h"
//#import "MPSDFileReadMangaer.h"
//
//static dispatch_queue_t ble_communication_queue() {
//    static dispatch_queue_t af_ble_communication_queue;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        af_ble_communication_queue = dispatch_queue_create("com.mociroport.ble.communication", DISPATCH_QUEUE_SERIAL);
//    });
//    return af_ble_communication_queue;
//}
//
//enum SD_COMMAND
//{
//    SD_NONE,
//    SD_INFO,
//    SD_ECG
//};
//
//@interface MPDBluetoothManager() <CBCentralManagerDelegate,CBPeripheralDelegate,UIActionSheetDelegate>
//@property (strong,nonatomic) CBCentralManager *centralManager;
//@property (nonatomic) NSInteger isPacketStart;
//@property (nonatomic) NSInteger packetLength;
//@property (nonatomic) uint8_t previousData;
//@property (nonatomic) NSMutableData *packetData;
//@property (nonatomic) BOOL isFirstPacket;
//@property NSArray* WEEKDAYS;
//@property NSMutableArray* fileData;
//@property (nonatomic) int HR;
//@property (nonatomic) uint16_t ECG;
//@property int firstAccx;
//@property int firstAccy;
//@property int firstAccz;
//@property BOOL first;
//@property (nonatomic) NSInteger bleCmdType;
//@property (nonatomic) NSString *connectedDeviceUDID;
//@property (nonatomic) BOOL connectDefault;
//@property int currentCmd;
//@property (nonatomic) BOOL reading;
//@property (nonatomic) NSMutableArray *median;
//@property (nonatomic) NSMutableDictionary *paramBuffer;
//@end
//
//@implementation MPDBluetoothManager
//
//#pragma mark - life cycle
//
//+(MPDBluetoothManager *)sharedManager{
//    static dispatch_once_t predicate;
//    static MPDBluetoothManager *bluetoothManager;
//    
//    dispatch_once(&predicate, ^{
//        bluetoothManager = [[MPDBluetoothManager alloc]init];
//        [bluetoothManager initCentralManager];
//    });
//    return bluetoothManager;
//    
//}
//
//-(void)initCentralManager{
//    if (self) {
//        self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue()];
//        if (!self.median) {
//            self.median = [[NSMutableArray alloc]init];
//        }
//        cwt_qrs_init();
//        _shouldScan = NO;
//        _connectDefault = NO;
//        _bleCmdType = MPDeviceCmdTypeNone;
//        [self getCurrentDeviceUUID];
//    }
//}
//
//
//-(void)dealloc{
//    [self saveCurrentDevice];
//}
//
//#pragma mark - ble connect methods
//-(void)scanForDevices{
//    //    if(!_shouldScan)
//    {
//        //        [_centralManager stopScan];
//        //        _shouldScan = YES;
//        [_centralManager scanForPeripheralsWithServices:nil options:nil/*@{ CBCentralManagerScanOptionAllowDuplicatesKey : @(NO) }*/];
//        [_centralManager scanForPeripheralsWithServices:nil options:nil/*@{ CBCentralManagerScanOptionAllowDuplicatesKey : @(NO) }*/];
//    }
//}
//
//-(void)stopScan{
//    _shouldScan = NO;
//    _shouldContinueScan = NO;
//    [_centralManager stopScan];
//}
//
//-(void)connectToDevice:(CBPeripheral *)peripheral{
//    self.forceClose = NO;
//    if(![[MPSDFileReadMangaer sharedManager] checkBTconnection:0 target:self.delegate])
//    {
//        return;
//    }
//    if (peripheral.state == CBPeripheralStateConnecting || peripheral.state == CBPeripheralStateConnected) {
//        return;
//    }
//    [_centralManager connectPeripheral:peripheral options:nil];
//}
//
//-(BOOL)hasDeviceConnected{
//    if (_connectedDevice) {
//        switch (_connectedDevice.state) {
//            case CBPeripheralStateConnected:
//                return YES;
//                break;
//            default:
//                break;
//        }
//    }
//    return NO;
//}
//
//-(CBPeripheral *)getCurrentConnectedDevice{
//    if (_connectedDevice != nil && _connectedDevice.state == CBPeripheralStateConnected) {
//        return _connectedDevice;
//    }
//    return nil;
//}
//
//-(void)disconnectCurrentDevice{
//    if ([self hasDeviceConnected]) {
//        [self disconnectToDevice:_connectedDevice];
//    }
//    _connectDefault = NO;
//}
//
//-(void)disconnectToDevice:(CBPeripheral *)peripheral{
//    _connectDefault = NO;
//    if(peripheral != nil)
//    {
//        self.forceClose = YES;
//        [_centralManager cancelPeripheralConnection:peripheral];
//    }
//}
//
//-(void)discoverServicesForCBPeripheral:(CBPeripheral *)peripheral withUUIDList:(NSArray *)UUIDList{
//    peripheral.delegate = self;
//    [peripheral discoverServices:UUIDList];
//}
//
//
//-(void)connectToDefaultDevice{
//    if(![[MPSDFileReadMangaer sharedManager] checkBTconnection:0 target:self.delegate])
//    {
//        return;
//    }
//    if (_connectedDevice == nil) {
//        if (_connectedDeviceUDID !=nil && ![_connectedDeviceUDID isEqualToString:EmptyStr]) {
//            _connectDefault = YES;
//            //            _shouldScan = NO;
//            [self scanForDevices];
//        }
//        return;
//    }
//    if (_connectedDevice.state != CBPeripheralStateConnected) {
//        _bleCmdType = MPDeviceCmdTypeNone;
//        [self connectToDevice:_connectedDevice];
//    }
//}
//
////cmd
//-(void)startReadEcgData{
//    if (_connectedDevice == nil) {
//        return;
//    }
//    [self reset];
//    if (_connectedDevice.state != CBPeripheralStateConnected) {
//        _bleCmdType = MPDeviceCmdTypeTypeAllOn;
//        self.reading = YES;
//        [self connectToDevice:_connectedDevice];
//        
//    }else{
//        _bleCmdType = MPDeviceCmdTypeTypeAllOn;
//        [self sendCmd:_bleCmdType];
//    }
//}
//
//#pragma mark Event
//-(void)startReadMarkEcg:(NSInteger)index
//{
//    [self.paramBuffer setObject:@(index) forKey:@"MarkIndex"];
//    [self cmdSDTX_ON_After:MPDeviceCmdTypeTypeSDMarkEcg];
//}
//-(void) startReadMarkList
//{
//    [self cmdSDTX_OFF_After:MPDeviceCmdTypeTypeSDListMark];
//    //[NSThread sleepForTimeInterval:1];
//    //[self readMarkList];
//}
//-(void)startReadSDFileList
//{
//    [self cmdSDTX_ON_After:MPDeviceCmdTypeTypeSDListFile];
//}
//
//-(void)startSDFormat
//{
//    [self cmdSDTX_OFF_After:MPDeviceCmdTypeTypeSDFormat];
//}
//-(void)readMarkEcg:(NSInteger)index{
//    if (_connectedDevice == nil) {
//        return;
//    }
//    [self reset];
//    NSString *cmd = @"S SDTX SD_MARK_ECG ";
//    cmd = [cmd stringByAppendingFormat:@"%ld",index];
//    cmd = [cmd stringByAppendingFormat:@"%c%c",0x0D,0x0A];
//    NSData *d = [cmd dataUsingEncoding:NSUTF8StringEncoding];
//     NSLog(@"%@",cmd);
//    self.bleCmdType = MPDeviceCmdTypeTypeSDMarkEcg;
//    [self writeValue:_connectedDevice data:d];
//    //[self notification:_connectedDevice on:YES];
//}
//-(void) readMarkList
//{
//    //NSString *cmd = @"S SDTX SD_MARK_LIST";
//    NSString *cmd = @"S SDTX INDDEX_LIST";
//
//    [self reset];
//    cmd = [cmd stringByAppendingFormat:@"%c%c",0x0D,0x0A];
//    NSData *d = [cmd dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"%@",cmd);
//    self.bleCmdType = MPDeviceCmdTypeTypeSDListMark;
//    [self writeValue:_connectedDevice data:d];
//    [self notification:_connectedDevice on:YES];
//}
//
//
//-(void)reset
//{
//    self.packetLength = 0;
//    self.isPacketStart = 0;
//    self.previousData = 0;
//    self.isFirstPacket = YES;
//    self.packetData = [[NSMutableData alloc] initWithCapacity:BT_SD_READ_PACKET_SIZE];
//    self.fileData = [[NSMutableArray alloc] init];
//    self.first = NO;
//    self.reading = NO;
//    self.paramBuffer = [NSMutableDictionary dictionary];
//}
//
//-(void)stopCurrentWork
//{
//    if(self.connectedDevice.state != CBPeripheralStateConnected)
//    {
//        return;
//    }
//    switch (_bleCmdType) {
//        case MPDeviceCmdTypeTypeAllOn:
//            [self stopReadEcgData];
//            break;
//        default:
//            break;
//    }
//}
//-(void)stopReadEcgData{
//    _bleCmdType = MPDeviceCmdTypeTypeAllOff;
//    //    [_connectedDevice discoverServices:nil];
//    [self sendCmd:_bleCmdType];
//    self.reading = NO;
//}
//
//-(void)getSDRecordState
//{
//    [self reset];
//    _bleCmdType = MPDeviceCmdTypeTypeSDRecordState;
//    [self sendCmd:_bleCmdType];
//}
//#pragma mark - ble cmd
//
//-(void)sendCmd:(NSInteger)cmdType{
//    NSData *d = nil;
//    switch (cmdType) {
//        case MPDeviceCmdTypeTypeAllOn:
//        {
//            unsigned char command[15] = {'S',' ','V','I','E','W',' ','A','L','L',' ','O','N',0x0D,0x0A};
//            d = [[NSData alloc] initWithBytes:command length:15];
//            break;
//        }
//        case MPDeviceCmdTypeTypeAllOff:
//        {
//            unsigned char command[16] = {'S',' ','V','I','E','W',' ','A','L','L',' ','O','F','F',0x0D,0x0A};
//            d = [[NSData alloc] initWithBytes:command length:16];
//            break;
//        }
//        case MPDeviceCmdTypeTypeSDRecordOn:
//        {
//            break;
//        }
//        case MPDeviceCmdTypeTypeSDRecordOff:
//        {
//            break;
//        }
//        case MPDeviceCmdTypeSetUserName:
//        {
//            break;
//        }
//        case MPDeviceCmdTypeTypeSDRecordState:
//        {
//            NSString *cmd = @"S SDREC STATE";
//            cmd = [cmd stringByAppendingFormat:@"%c%c",0x0D,0x0A];
//            d = [cmd dataUsingEncoding:NSUTF8StringEncoding];
//            break;
//        }
//        default:
//            break;
//    }
//    if(d)
//    {
//        //        dispatch_async(ble_communication_queue(), ^(void){
//        [self reset];
//        [self writeValue:_connectedDevice data:d];
//        [self notification:_connectedDevice on:YES];
//        //        });
//    }
//}
//
//#pragma mark - CBCentralManagerDelegate
//- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
//    NSString *managerState = EmptyStr;
//    switch (central.state) {
//        case CBCentralManagerStatePoweredOn:
//        {
//            managerState = @"work";
//            if (_shouldScan) {
//                [self scanForDevices];
//            }
//            break;
//        }
//            ///TODO
//        case CBCentralManagerStatePoweredOff:
//            managerState = @"PoweredOff";
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"BluetoothPowerOff" object:nil];
//            break;
//        case CBCentralManagerStateResetting:
//            managerState = @"Resetting";
//            break;
//        case CBCentralManagerStateUnauthorized:
//            managerState = @"Unauthorized";
//            break;
//        case CBCentralManagerStateUnknown:
//            managerState = @"Unknown";
//            break;
//        default:
//            break;
//    }
//}
//
//-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
//    peripheral.delegate = self;
//    self.forceClose = NO;
//    _connectedDevice = peripheral;
//    [self saveCurrentDevice];
//    if(!_shouldContinueScan)
//    {
//        [self stopScan];
//    }
//    
//    [peripheral discoverServices:nil];
//    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothManager:resultType:operationType:resultDic:msg:)])
//    {
//        [self.delegate bluetoothManager:self resultType:MPDBluetoothMangagerOperationResult_Success operationType:MPDBluetoothMangagerOperationType_Connect resultDic:@{@"peripheral":peripheral} msg:nil];
//    }
//    [[NSNotificationCenter defaultCenter]postNotificationName:kDeviceConnectStatusChangedNotification object:@{@"device":_connectedDevice,@"forceClose":@(self.forceClose)}];
//    self.forceClose = NO;
//    if(self.reading)
//    {
//        [self startReadEcgData];
//    }
//}
//
//-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
//    self.reading = NO;
//    //    _connectedDevice = nil;
//    NSInteger opeationResult;
//    NSString *errMsg = nil;
//    if (error) {
//        errMsg = [error localizedDescription];
//        opeationResult = MPDBluetoothMangagerOperationResult_Fail;
//    }else{
//        
//        opeationResult = MPDBluetoothMangagerOperationResult_Success;
//    }
//    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothManager:resultType:operationType:resultDic:msg:)])
//    {
//        [self.delegate bluetoothManager:self resultType:opeationResult operationType:MPDBluetoothMangagerOperationType_Connect resultDic:@{@"peripheral":peripheral} msg:errMsg];
//    }
//    
//    [[NSNotificationCenter defaultCenter]postNotificationName:kDeviceConnectStatusChangedNotification object:@{@"device":_connectedDevice,@"forceClose":@(self.forceClose)}];
//    self.forceClose = NO;
//}
//
//-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
//    if (_connectedDeviceUDID !=nil && ![_connectedDeviceUDID isEqualToString:EmptyStr] && [_connectedDeviceUDID isEqualToString:peripheral.identifier.UUIDString] && _connectDefault) {
//        //        [self stopScan];
//        [self connectToDevice:peripheral];
//        _connectDefault = NO;
//    }
//    if (_discoverdPeriparals != nil && _discoverdPeriparals.count > 0) {
//        for (CBPeripheral *peri in _discoverdPeriparals) {
//            if ([peri.identifier.UUIDString isEqualToString: peripheral.identifier.UUIDString] || ![self shouldAddToList:peripheral]) {
//                return;
//            }
//        }
//    }
//    if (_discoverdPeriparals == nil) {
//        _discoverdPeriparals = [[NSMutableArray alloc]init];
//    }
//    if (![self shouldAddToList:peripheral]) {
//        return;
//    }
//    [_discoverdPeriparals addObject:peripheral];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kBleDeviceChangedNotification object:peripheral];
//    if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothManager:resultType:operationType:resultDic:msg:)])
//    {
//        [self.delegate bluetoothManager:self resultType:MPDBluetoothMangagerOperationResult_Success operationType:MPDBluetoothMangagerOperationType_Scan resultDic:@{@"peripheral":peripheral} msg:nil];
//    }
//}
//
//-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
//    [ToastUtil showPromptToast:NSLocalizedString(@"蓝牙连接失败",nil)];
//}
//
//#pragma mark - CBPeripheralDelegate
//-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
//    if (error) {
//        NSLog(@"Discovered services for %@ with error: %@",peripheral.name,[error localizedDescription]);
//        if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothManager:resultType:operationType:resultDic:msg:)])
//        {
//            [self.delegate bluetoothManager:self resultType:MPDBluetoothMangagerOperationResult_Fail operationType:MPDBluetoothMangagerOperationType_Read resultDic:@{@"peripheral":peripheral} msg:[error localizedDescription]];
//        }
//        [self showErrMsg:LocalizedStr(@"Ble read failed")];
//    }else{
//        for (CBService *service in peripheral.services) {
//            NSLog(@"service's UUID is %@",service.UUID);
//            [peripheral discoverCharacteristics:nil forService:service];
//        }
//    }
//}
//
//-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
//    if (error) {
//        if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothManager:resultType:operationType:resultDic:msg:)])
//        {
//            [self.delegate bluetoothManager:self resultType:MPDBluetoothMangagerOperationResult_Fail operationType:MPDBluetoothMangagerOperationType_Read resultDic:nil msg:[error localizedDescription]];
//        }
//        [self showErrMsg:LocalizedStr(@"Ble read failed")];
//        return;
//    }
//    
//    NSLog(@"service is %@",service.UUID);
//    
//    for (int i= 0 ; i < service.characteristics.count; i++) {
//        
//        CBService *s = [peripheral.services objectAtIndex:(peripheral.services.count - 1)];
//        if([self compareCBUUID:service.UUID UUID2:s.UUID]) {
//            if([self.delegate respondsToSelector:@selector(deviceReady)])
//            {
//                [self.delegate deviceReady];
//            }
//        }
//    }
//}
//
//-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
//    if (error) {
//        if(self.delegate && [self.delegate respondsToSelector:@selector(bluetoothManager:resultType:operationType:resultDic:msg:)])
//        {
//            [self.delegate bluetoothManager:self resultType:MPDBluetoothMangagerOperationResult_Fail operationType:MPDBluetoothMangagerOperationType_Read resultDic:nil msg:[error localizedDescription]];
//        }
//        [self showErrMsg:LocalizedStr(@"Ble read failed")];
//        return;
//    }
//    NSString *head = [peripheral.name substringToIndex:2];
//    if ([head isEqualToString:@"DV"]) {
//        [self dealWithDVData:characteristic];
//    }
//    else if([head isEqualToString:@"MP"])
//    {
//        [self dealWithMPData:characteristic];
//    }
//}
//
//- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
//    if (error) {
//        [self showErrMsg:LocalizedStr(@"Ble read failed")];
//        return;
//    }
//}
//
//-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
//    NSLog(@"didWriteValueForCharacteristic:%@",characteristic.UUID.UUIDString);
//    if (error) {
//        NSLog(@"didWriteValueForCharacteristic:%@ error:%@",characteristic,[error localizedDescription]);
//        [self showErrMsg:LocalizedStr(@"Ble read failed")];
//    }
//}
//
//#pragma mark - main
////from old src
//-(BOOL)shouldAddToList:(CBPeripheral *)peripheral{
//    NSLog(@"peripheral's name %@",peripheral.name);
//    if ([peripheral.name hasPrefix:@"DV"] || [peripheral.name containsString:@"MP"]/*[peripheral.name containsString:@"HOME"]*/) {
//        return YES;
//    }
//    return NO;
//}
//
//-(UInt16) CBUUIDToInt:(CBUUID *) UUID {
//    char b1[16];
//    [UUID.data getBytes:b1 length:sizeof(b1)];
//    return ((b1[0] << 8) | b1[1]);
//}
//
//-(void)dealWithMPData:(CBCharacteristic *)characteristic{
//    UInt16 characteristicUUID = [self CBUUIDToInt:characteristic.UUID];
//    //    int i = 0;
//    //    NSUInteger receiveLength = [characteristic.value length];
//    switch(characteristicUUID){
//        case IMEC_BLE_HR_VALUE:
//        {
//            NSData *array = [characteristic value];
//            //                 NSString *dataString = @"";
//            //                 NSString *dataStringBaseLine = @"";
//            int i;
//            unsigned char *data;
//            data = (unsigned char*)malloc([array length]);
//            [array getBytes:data length:[array length]];
//            NSMutableArray *arr = [NSMutableArray array];
//            for (i =1; i<16; i+=2) {
//                UInt16 ecg = data[i]+(data[i+1]*256);
//                //                     dataString = [dataString stringByAppendingFormat:@"%d ",ecg];
//                //                     float fecg = (((float)ecg * 1.05 *1000)/(4095*ECG_GAIN));
//                //                     if(self.isShow == YES)
//                //                     {
//                //                         fecg = baselineRemove(fecg);
//                //                         [self showECG:fecg];
//                //                         [self medianFilterAndHeartRate:ecg];
//                //                     }
//                //                     int fecgADC= ((fecg*4095*ECG_GAIN)/1050);
//                //                     dataStringBaseLine = [dataStringBaseLine stringByAppendingFormat:@"%d ",fecgADC];
//                
//                [self.median addObject:[NSNumber numberWithInt:ecg]];
//                if ([self.median count]>=73)
//                {
//                    [self.median removeObjectAtIndex:0];
//                    NSArray *sorted = [self.median sortedArrayUsingSelector:@selector(compare:)];    // Sort the array by value
//                    NSUInteger middle = [sorted count] / 2;                                           // Find the index of the middle element
//                    NSNumber *median = [sorted objectAtIndex:middle];
//                    
//                    int hr = cwt_qrs(ecg - [median intValue]);
//                    if(hr!= IMPOSSIBLE_HR)
//                    {
//                        self.HR = hr;
//                        [[self delegate] hrValuesUpdated:self.HR];
//                    }
//                }
//                
//                self.ECG = ecg;
//                [arr addObject:@(self.ECG)];
//                //                if([self.delegate respondsToSelector:@selector(ecgValuesUpdated:)])
//                //                {
//                //                    [[self delegate] ecgValuesUpdated:self.ECG];
//                //                }
//            }
//            if([self.delegate respondsToSelector:@selector(ecgValuesUpdated:)])
//            {
//                [[self delegate] ecgValuesUpdated:arr];
//            }
//            
//            NSUInteger battery;
//            battery = data[i];
//            if([self.delegate respondsToSelector:@selector(batteryValuesUpdated:)])
//            {
//                [[self delegate] batteryValuesUpdated:battery];
//            }
//            
//            
//            //                 [self.labelHR setText:[NSString stringWithFormat:@"HR:%ld Battery:%ld",self.heartRate,self.battery]];
//            
//            
//            //
//            //             const uint8_t *hrData = [characteristic.value bytes];
//            //
//            //             self.HR = (int)hrData[1];
//            //
//            //
//            //
//            //             [[self delegate] hrValuesUpdated:self.HR];
//            
//            break;
//            
//        }
//        default:
//            break;
//    }
//}
//
//-(void)dealWithDVData:(CBCharacteristic *)characteristic{
//    
//    UInt16 characteristicUUID = [self CBUUIDToInt:characteristic.UUID];
//    int i = 0;
//    NSUInteger receiveLength = [characteristic.value length];
//    switch(characteristicUUID){
//        case IMEC_BLE_BATTERY_LEVEL:
//        {
//            const char *data = (const char *)[characteristic.value bytes];
//            //            NSLog(@"data : %@",characteristic.value);
//            for (i =0; i<receiveLength ;i++)
//            {
//                //                NSLog(@"receiveLength:%ld",receiveLength);
//                //                NSLog(@"data[i]:%c",(char)data[i]);
//                //                NSLog(@"self.packetData length:%ld",[self.packetData length]);
//                //                NSLog(@"self.packetLength:%ld",_packetLength);
//                //                NSLog(@"self.isPacketStart:%ld",self.isPacketStart);
//                if (data[i] == 0x53 && self.isPacketStart == 0) {
//                    if (self.previousData == 0x50 || self.isFirstPacket)
//                    {
//                        self.isFirstPacket = NO;
//                        self.isPacketStart = 1;
//                        self.packetData =[[NSMutableData alloc]initWithCapacity:BT_SD_READ_PACKET_SIZE];
//                    }
//                    else
//                    {
//                        self.isPacketStart = 0;
//                        NSLog(@"bad packet");
//                    }
//                }
//                else if (data[i] != 0x50 && self.isPacketStart == 2 && [self.packetData length] == self.packetLength + 1){
//                    NSLog(NSLocalizedString(@"协议错误",nil));
//                    self.isPacketStart = 0;
//                    
//                }
//                else if (data[i] == 0x50 && self.isPacketStart == 2 && [self.packetData length] == self.packetLength + 1){
//                    self.isPacketStart = 0;
//                    static uint8_t payLoad0[BT_SD_READ_PACKET_SIZE];
//                    int j =1;
//                    [self.packetData getBytes:payLoad0 length:BT_SD_READ_PACKET_SIZE];
//                    if (payLoad0[0] == 0x00) {
//                        // ECG packet
//                        NSMutableArray *arr = [NSMutableArray array];
//                        for (j = 1;j < _packetLength; j += 2)
//                        {
//                            UInt16 ecg = ((char)(payLoad0[j])<<8) +payLoad0[j+1];
//                            self.ECG = ecg;
//                            [arr addObject:@(ecg)];
//                            //                            if([self.delegate respondsToSelector:@selector(ecgValuesUpdated:)])
//                            //                            {
//                            //                                [[self delegate] ecgValuesUpdated:self.ECG];
//                            //                            }
//                        }
//                        if([self.delegate respondsToSelector:@selector(ecgValuesUpdated:)])
//                        {
//                            [[self delegate] ecgValuesUpdated:arr];
//                        }
//                    }
//                    else if (payLoad0[0] == 0x02) {
//                        // ACC packet
//                        for (j = 1;j < 24; j += 6)
//                        {
//                            int16_t accx = 0;
//                            accx |= (payLoad0[j+1]<<8);
//                            accx |= payLoad0[j];
//                            
//                            int16_t accy= 0;
//                            accy |= (payLoad0[j+3]<<8);
//                            accy |= payLoad0[j+2];
//                            
//                            int16_t accz = 0;
//                            accz |= (payLoad0[j+5]<<8);
//                            accz |= payLoad0[j+4];
//                            if (self.first == NO) {
//                                self.first = YES;
//                                self.firstAccx = accx;
//                                self.firstAccy = accy;
//                                self.firstAccz = accz;
//                            }
//                            if([self.delegate respondsToSelector:@selector(accValuesUpdated:y:z:)])
//                            {
//                                [[self delegate] accValuesUpdated:self.firstAccx-accx y:accy-self.firstAccy z:accz-self.firstAccz];
//                            }
//                        }
//                    }
//                    else if(payLoad0[0] == 0x05){
//                        // Heart packet
//                        UInt16 hr = payLoad0[1]+payLoad0[2]*256;
//                        self.HR = hr;
//                        if([self.delegate respondsToSelector:@selector(hrValuesUpdated:)])
//                        {
//                            [[self delegate] hrValuesUpdated:self.HR];
//                        }
//                    }
//                    else if(payLoad0[0] == 0x0B ){
//                        // Battery
//                        UInt16 battery = payLoad0[1]+payLoad0[2]*256;
//                        //
//                        //                        self.batteryLevel = battery;
//                        if([self.delegate respondsToSelector:@selector(batteryValuesUpdated:)])
//                        {
//                            [[self delegate] batteryValuesUpdated:battery];
//                        }
//                    }else if(payLoad0[0] == 0x0F ){
//                        // Connection
//                        UInt16 connection = payLoad0[1]+payLoad0[2]*256;
//                        if([self.delegate respondsToSelector:@selector(connectionValuesUpdated:)])
//                        {
//                        [[self delegate] connectionValuesUpdated:connection];
//                        }
//                    }
//                }
//                
//                else if ([self.packetData length] == self.packetLength + 1 && self.isPacketStart == 3){
//                    if(data[i] == 0x50)
//                    {
//                        self.isPacketStart = 0;
//                        //NSLog(@"parse packet %@",self.packetData);
//                        static uint8_t payLoad[BT_SD_READ_PACKET_SIZE];
//                        
//                        [self.packetData getBytes:payLoad length:BT_SD_READ_PACKET_SIZE];
//                        
//                        switch (payLoad[0])
//                        {
//                                
//                                //-- Status
//                            case 0x0D:{
//                                
//                                NSString *value = [[NSString alloc] initWithData:self.packetData encoding:NSUTF8StringEncoding];
//                                NSArray *arr = [value componentsSeparatedByString:@" "];
//                                if(value && [value containsString:@"SDREC_"])
//                                {
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
//                                }
//                                else if( value && [value containsString:@"SDR_"])
//                                {
//                                    if([value containsString:@"SDR_ON"])
//                                    {
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
//                                    }
//                                    else
//                                    {
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
//                                        
//                                    }
//                                }
//                                else if([value containsString:@"WRONG_COMMAND"])
//                                {
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
//                                }
//                                else if([value containsString:@"FORMATING"])
//                                {
//                                    NSLog(@"FORMATTING");
//                                }
//                            }
//                                break;
//                                //-- File : start
//                            case 0x03:{
//                                NSLog(@"%@",@"File - start!");
//                                break;}
//                                //-- File : end
//                            case 0x04:{
//                                NSLog(@"%@",@"File - end!");
//#ifdef NewFunc2Hour
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
//#else
//                                if([self.delegate respondsToSelector:@selector(fileUpdated:)])
//                                {
//                                    [[self delegate] fileUpdated:[self.fileData copy]];
//                                }
//#endif
//                                [_fileData removeAllObjects];
//                                break;}
//                                //-- File : data
//                            case 0x0E:{
//                                NSLog(@"%@",@"File - data!");
//                                
//                                for (int k = 1; k <= self.packetLength; ++k)
//                                {
//                                    [self.fileData addObject:[NSNumber numberWithUnsignedChar:payLoad[k]]];
//                                }
//                                break;}
//                                case 0x07:
//                                {
//                                    NSLog(@"%@",@"Mark File - data!");
//                                    
//                                    for (int k = 1; k <= self.packetLength; ++k)
//                                    {
//                                        [self.fileData addObject:[NSNumber numberWithUnsignedChar:payLoad[k]]];
//                                    }
//                                }
//                                //--
//                            default:{
//                                break;}
//                        }
//                        
//                    }
//                    else
//                    {
//                        self.isPacketStart = 0;
//                        //                        self.badPacketNumber++;
//                    }
//                }
//                
//                else if(self.isPacketStart == 1){
//                    self.isPacketStart = 2;
//                    self.packetLength = data[i];
//                }
//                //                else if(self.isPacketStart == 2){
//                //                    [self.packetData appendData:[NSData dataWithBytes:&data[i] length:1]];
//                //                }
//                else if(self.isPacketStart == 2){
//                    static uint8_t payLoad1[BT_SD_READ_PACKET_SIZE];
//                    [self.packetData getBytes:payLoad1 length:BT_SD_READ_PACKET_SIZE];
//                    if(payLoad1[0] == 0x0E || payLoad1[0] == 0x03 || payLoad1[0] == 0x04 || payLoad1[0] == 0x0D || payLoad1[0] == 0x07)
//                    {
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
//                        [self.packetData appendData:[NSData dataWithBytes:&data[i] length:1]];
//                    }
//                    else
//                    {
//                        [self.packetData appendData:[NSData dataWithBytes:&data[i] length:1]];
//                    }
//                }
//                
//                else if(self.isPacketStart == 3){
//                    [self.packetData appendData:[NSData dataWithBytes:&data[i] length:1]];
//                }
//                else
//                {
//                    self.isPacketStart = 0;
//                    NSLog(@"bad packet");
//                }
//                self.previousData = data[i];
//                //                NSLog(@"[self.packetData length]:%ld",[self.packetData length]);
//                //                NSLog(@"self.packetLength:%ld",self.packetLength);
//                //                NSLog(@"self.isPacketStart:%ld",self.isPacketStart);
//            }
//        }
//            break;
//            /*
//             case IMEC_BLE_RES_VALUE:
//             {
//             
//             NSUInteger resDataLength = [characteristic.value length];
//             
//             const uint8_t *resData = [characteristic.value bytes];
//             
//             for (int i = 0 ; i< resDataLength ; i+=2)
//             {
//             
//             
//             uint16_t ResValue = ( (resData[i] << 8 ) + resData[i+1] );
//             
//             // NSLog(@"%@%hu",@"from parse :", ResValue);
//             self.RES = ResValue;
//             [[self delegate] resValuesUpdated:self.RES];
//             
//             
//             
//             }
//             
//             
//             
//             break;
//             }
//             
//             
//             
//             case IMEC_BLE_BATTERY_LEVEL:
//             {
//             char batlevel;
//             [characteristic.value getBytes:&batlevel length:1];
//             self.batteryLevel = (float)batlevel;
//             [[self delegate] batteryValuesUpdated:self.batteryLevel];
//             
//             break;
//             
//             }
//             
//             case IMEC_BLE_HR_VALUE:
//             {
//             NSData *array = [characteristic value];
//             //                 NSString *dataString = @"";
//             //                 NSString *dataStringBaseLine = @"";
//             int i;
//             unsigned char *data;
//             data = (unsigned char*)malloc([array length]);
//             [array getBytes:data length:[array length]];
//             for (i =1; i<16; i+=2) {
//             UInt16 ecg = data[i]+(data[i+1]*256);
//             //                     dataString = [dataString stringByAppendingFormat:@"%d ",ecg];
//             //                     float fecg = (((float)ecg * 1.05 *1000)/(4095*ECG_GAIN));
//             //                     if(self.isShow == YES)
//             //                     {
//             //                         fecg = baselineRemove(fecg);
//             //                         [self showECG:fecg];
//             //                         [self medianFilterAndHeartRate:ecg];
//             //                     }
//             //                     int fecgADC= ((fecg*4095*ECG_GAIN)/1050);
//             //                     dataStringBaseLine = [dataStringBaseLine stringByAppendingFormat:@"%d ",fecgADC];
//             
//             [self.median addObject:[NSNumber numberWithInt:ecg]];
//             if ([self.median count]>=73)
//             {
//             [self.median removeObjectAtIndex:0];
//             NSArray *sorted = [self.median sortedArrayUsingSelector:@selector(compare:)];    // Sort the array by value
//             NSUInteger middle = [sorted count] / 2;                                           // Find the index of the middle element
//             NSNumber *median = [sorted objectAtIndex:middle];
//             
//             int hr = cwt_qrs(ecg-[median intValue]);
//             if(hr!= IMPOSSIBLE_HR)
//             {
//             self.HR = hr;
//             [[self delegate] hrValuesUpdated:self.HR];
//             }
//             }
//             
//             self.ECG = ecg;
//             if([self.delegate respondsToSelector:@selector(ecgValuesUpdated:)])
//             {
//             [[self delegate] ecgValuesUpdated:self.ECG];
//             }
//             }
//             
//             //                 NSUInteger battery;
//             //                 battery = data[i];
//             
//             
//             //                 [self.labelHR setText:[NSString stringWithFormat:@"HR:%ld Battery:%ld",self.heartRate,self.battery]];
//             
//             
//             //             
//             //             const uint8_t *hrData = [characteristic.value bytes];
//             //             
//             //             self.HR = (int)hrData[1];
//             //             
//             //             
//             //             
//             //             [[self delegate] hrValuesUpdated:self.HR];
//             
//             break;
//             
//             }
//             
//             case IMEC_BLE_ECG_VALUE:
//             {
//             
//             
//             NSUInteger ecgDataLength = [characteristic.value length];
//             
//             const uint8_t *ecgData = [characteristic.value bytes];
//             
//             
//             
//             
//             
//             for (int i = 0 ; i< ecgDataLength ; i+=2)
//             {
//             
//             
//             
//             
//             uint16_t ECGValue = ( ((0x0F & ecgData[i]) << 8 ) + ecgData[i+1] );
//             
//             
//             
//             self.ECG = ECGValue;
//             [[self delegate] ecgValuesUpdated:self.ECG];
//             
//             
//             }
//             
//             
//             break;
//             }
//             
//             
//             case IMEC_BLE_ACC_VALUE:
//             {
//             
//             
//             
//             const int8_t *accData = [characteristic.value bytes];
//             
//             NSMutableArray *AccArray = [[NSMutableArray alloc]init];
//             
//             for (int i =0 ; i < 18; i+=2)
//             {
//             
//             
//             
//             uint8_t accMSB = accData[i];
//             uint8_t accLSB = accData[i+1];
//             
//             
//             
//             int16_t accValue = (int16_t)(accLSB + [self accDataParse:accMSB]);
//             
//             
//             
//             [AccArray addObject:[NSNumber numberWithInt:accValue]];
//             
//             
//             
//             
//             
//             
//             
//             }
//             
//             for(int j = 0 ; j<9 ; j+=3)
//             {
//             
//             [[self delegate] accValuesUpdated:[[AccArray objectAtIndex:j] integerValue] y:[[AccArray objectAtIndex:j+1] integerValue] z:[[AccArray objectAtIndex:j+2] integerValue]];
//             
//             }
//             
//             
//             
//             
//             
//             
//             
//             
//             
//             
//             break;
//             }
//             
//             
//             
//             case TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_UUID:
//             {
//             char TXLevel;
//             [characteristic.value getBytes:&TXLevel length:TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_READ_LEN];
//             self.TXPwrLevel = TXLevel;
//             [[self delegate] TXPwrLevelUpdated:TXLevel];
//             }
//             */
//        default:
//            break;
//    }
//}
//
////-(void)reset{
////    _connectedDevice = nil;
////    [_discoverdPeriparals removeAllObjects];
////}
//
//-(void)showErrMsg:(NSString *)errMsg{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [UUProgressHUD dismissWithError:errMsg];
//    });
//    
//}
//
//
//-(NSString *)getCurrentDeviceUUID{
//    _connectedDeviceUDID = [StorePath valueForKey:kCurrentDeviceUUID];
//    return _connectedDeviceUDID;
//}
//
//-(NSString *)getCurrentDeviceName{
//    return [StorePath valueForKey:kCurrentDeviceName];
//}
//
//-(void)saveCurrentDevice{
//    if (_connectedDevice) {
//        [StorePath setValue:_connectedDevice.identifier.UUIDString forKey:kCurrentDeviceUUID];
//        [StorePath setValue:_connectedDevice.name forKey:kCurrentDeviceName];
//        [StorePath synchronize];
//    }
//}
//
//- (UInt16) uartServiceUUID
//{
//    return IMEC_BLE_BATTERY_SERVICE;
//}
//
//- (UInt16) txCharacteristicUUID
//{
//    return IMEC_BLE_BATTERY_LEVEL;
//}
//
//- (UInt16) rxCharacteristicUUID
//{
//    return IMEC_BLE_BATTERY_LEVEL;
//}
//
////home use
//- (UInt16) uartServiceUUID2
//{
//    return IMEC_BLE_HR_SERVICE;
//}
//
//- (UInt16) rxCharacteristicUUID2
//{
//    return IMEC_BLE_HR_VALUE;
//}
//
//- (UInt16) txCharacteristicUUID2
//{
//    return IMEC_BLE_HR_VALUE2;
//}
//
//- (UInt16) deviceInformationServiceUUID
//{
//    return IMEC_BLE_BATTERY_SERVICE;
//}
///*
// -(void) writeValue:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data {
// CBUUID *su = serviceUUID;
// CBUUID *cu = characteristicUUID;
// CBService *service = [self findServiceFromUUID:su p:p];
// //    if (!service) {
// //        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[[p.identifier UUIDString] cStringUsingEncoding:NSUTF8StringEncoding]);
// //        return;
// //    }
// CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
// if (!characteristic) {
// printf("Could not find characteristic with UUID %s on service with UUID on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[[p.identifier UUIDString] cStringUsingEncoding:NSUTF8StringEncoding]);
// //        return;
// for (CBService *sv in _connectedDevice.services) {
// for(CBCharacteristic *cb in sv.characteristics)
// {
// [p writeValue:data forCharacteristic:cb type:CBCharacteristicWriteWithResponse];
// }
// }
// }
// else
// {
// [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
// }
// 
// }
// */
//-(void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data {
//    UInt16 s = [self swap:serviceUUID];
//    UInt16 c = [self swap:characteristicUUID];
//    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
//    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
//    CBUUID *su = [CBUUID UUIDWithData:sd];
//    CBUUID *cu = [CBUUID UUIDWithData:cd];
//    CBService *service = [self findServiceFromUUID:su p:p];
//    if (!service) {
//        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[[p.identifier UUIDString] cStringUsingEncoding:NSUTF8StringEncoding]);
//        return;
//    }
//    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
//    if (!characteristic) {
//        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s \r\n",[self CBUUIDToString:cu],[[p.identifier UUIDString] cStringUsingEncoding:NSUTF8StringEncoding]);
//        return;
//    }
//    
//    NSString *va = [[NSString alloc]  initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"output:%@",va);
//    [NSThread sleepForTimeInterval:0.1];
//    [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
//    
//}
//-(void) writeValue:(CBPeripheral *)p data:(NSData *)data
//{
//    NSString *head = [p.name substringToIndex:2];
//    if ([head isEqualToString:@"DV"]) {
//        [self writeValue:[self uartServiceUUID] characteristicUUID:[self txCharacteristicUUID] p:p data:data];
//    }
//    else if([head isEqualToString:@"MP"])
//    {
//        [self writeValue:[self uartServiceUUID2] characteristicUUID:[self txCharacteristicUUID2] p:p data:data];
//    }
//    
//}
//
//-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on {
//    UInt16 s = [self swap:serviceUUID];
//    UInt16 c = [self swap:characteristicUUID];
//    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
//    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
//    CBUUID *su = [CBUUID UUIDWithData:sd];
//    CBUUID *cu = [CBUUID UUIDWithData:cd];
//    CBService *service = [self findServiceFromUUID:su p:p];
//    if (!service) {
//        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[[p.identifier UUIDString] cStringUsingEncoding:NSUTF8StringEncoding]);
//        return;
//    }
//    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
//    if (!characteristic) {
//        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[[p.identifier UUIDString] cStringUsingEncoding:NSUTF8StringEncoding]);
//        return;
//    }
//    [p setNotifyValue:on forCharacteristic:characteristic];
//}
//
//-(void) notification:(CBPeripheral *)p on:(BOOL)on
//{
//    NSString *head = [p.name substringToIndex:2];
//    if ([head isEqualToString:@"DV"]) {
//        [self notification:[self uartServiceUUID] characteristicUUID:[self rxCharacteristicUUID] p:p on:on];
//    }
//    else if([head isEqualToString:@"MP"])
//    {
//        [self notification:[self uartServiceUUID2] characteristicUUID:[self rxCharacteristicUUID2] p:p on:on];
//    }
//}
//-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p {
//    for(int i = 0; i < p.services.count; i++) {
//        CBService *s = [p.services objectAtIndex:i];
//        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
//    }
//    return nil;
//}
//
//-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
//    if(service)
//    {
//        for(int i=0; i < service.characteristics.count; i++) {
//            CBCharacteristic *c = [service.characteristics objectAtIndex:i];
//            if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
//        }
//    }
//    else
//    {
//        for (CBService *sv in _connectedDevice.services) {
//            for(CBCharacteristic *cb in sv.characteristics)
//            {
//                if ([self compareCBUUID:cb.UUID UUID2:UUID])
//                {
//                    return cb;
//                }
//            }
//        }
//    }
//    return nil;
//}
//
//-(const char *) CBUUIDToString:(CBUUID *) UUID {
//    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
//}
//
//-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2 {
//    char b1[16];
//    char b2[16];
//    //    [UUID1.data getBytes:b1];
//    //    [UUID2.data getBytes:b2];
//    [UUID1.data getBytes:b1 length:16];
//    [UUID2.data getBytes:b2 length:16];
//    if (memcmp(b1, b2, UUID1.data.length) == 0)return 1;
//    else return 0;
//}
//
//-(UInt16) swap:(UInt16)s {
//    UInt16 temp = s << 8;
//    temp |= (s >> 8);
//    return temp;
//}
//
//-(void)setUsername:(NSString *)name //发送给设备当前的监测人识别名
//{
//    [self reset];
//    NSString *cmd = @"S USERNAME ";
//    cmd = [cmd stringByAppendingString:name];
//    cmd = [cmd stringByAppendingFormat:@"%c%c",0x0D,0x0A];
//    
//    if (cmd.length <= 20)
//    {
//        NSData *d = [cmd dataUsingEncoding:NSUTF8StringEncoding];
//        NSLog(@"%@%@",@"cmd_user : ",cmd);
//        [self writeValue:_connectedDevice data:d];
//        [self notification:_connectedDevice on:YES];
//    }
//    else
//    {
//        NSString *cmdFirst =  [cmd substringToIndex:20];
//        NSData *dFirst = [cmdFirst dataUsingEncoding:NSUTF8StringEncoding];
//        NSLog(@"%@%@",@"cmd_Username_First : ",cmdFirst);
//        [self writeValue:_connectedDevice data:dFirst];
//        [self notification:_connectedDevice on:YES];
//        
//        
//        NSString *cmdSecond = [cmd substringFromIndex:20];
//        NSData *dSecond = [cmdSecond dataUsingEncoding:NSUTF8StringEncoding];
//        NSLog(@"%@%@",@"cmd_Username_Second ",cmdSecond);
//        [self writeValue:_connectedDevice data:dSecond];
//        [self notification:_connectedDevice on:YES];
//    }
//}
//
//-(void)startSDRecord:(NSString *)duration peripheral:(CBPeripheral *)p
//{
//    [self reset];
//    _bleCmdType = MPDeviceCmdTypeTypeSDRecordOn;
//    NSString *cmd = @"S SDREC ON ";
//    cmd = [cmd stringByAppendingString:duration];
//    cmd = [cmd stringByAppendingFormat:@"%c%c",0x0D,0x0A];
//    NSData *d = [cmd dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"%@%@",@"cmd_record : ",cmd);
//    [self writeValue:p data:d];
//    [self notification:_connectedDevice on:YES];
//}
//
//-(void)stopSDRecord
//{
//    [self reset];
//    _bleCmdType = MPDeviceCmdTypeTypeSDRecordOff;
//    NSString *cmd = @"S SDREC OFF";
//    cmd = [cmd stringByAppendingFormat:@"%c%c",0x0D,0x0A];
//    NSData *d = [cmd dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"%@%@",@"cmd_stopRecord : ",cmd);
//    [self writeValue:_connectedDevice data:d];
//}
//
//-(void)listSDFile
//{
//    [self reset];
//    _bleCmdType = MPDeviceCmdTypeTypeSDListFile;
//    NSString *cmd = @"S SDTX INDEX_LIST";
//    cmd = [cmd stringByAppendingFormat:@"%c%c",0x0D,0x0A];
//    NSData *d = [cmd dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"%@%@",@"cmd_File : ",cmd);
//    [self writeValue:_connectedDevice data:d];
//}
//-(void)formatSDCard
//{
//    [self reset];
//    _bleCmdType = MPDeviceCmdTypeTypeSDFormat;
//    NSString *cmd = @"S SDTX FORMAT";
//    cmd = [cmd stringByAppendingFormat:@"%c%c",0x0D,0x0A];
//    NSData *d = [cmd dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"%@%@",@"cmd_File : ",cmd);
//    [self writeValue:_connectedDevice data:d];
//}
//-(void)cmdSDTX_ON_After:(MPDeviceCmdType) afterOn
//{
//    if(afterOn != MPDeviceCmdTypeNone)
//    {
//        self.bleCmdType = afterOn;
//    }
//    else
//    {
//        self.bleCmdType = MPDeviceCmdTypeTypeSDTXOn;
//    }
//    NSString *cmd = @"S SDTX ON";
//    //NSString *cmd = @"S SDTX STATE";
//    cmd = [cmd stringByAppendingFormat:@"%c%c",0x0D,0x0A];
//    NSData *d = [cmd dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"%@%@",@"cmd_SDTX_ON : ",cmd);
//    [self writeValue:self.connectedDevice data:d];
//}
//
//-(void)cmdSDTX_OFF_After:(MPDeviceCmdType) afterOff
//{
//    if(afterOff != MPDeviceCmdTypeNone)
//    {
//        self.bleCmdType = afterOff;
//    }
//    else
//    {
//        self.bleCmdType = MPDeviceCmdTypeTypeSDSDTXOff;
//    }
//    NSString *cmd = @"S SDTX OFF";
//    cmd = [cmd stringByAppendingFormat:@"%c%c",0x0D,0x0A];
//    NSData *d = [cmd dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"%@%@",@"cmd_SDTX_OFF : ",cmd);
//    [self writeValue:self.connectedDevice data:d];
//}
//
//
//-(void)setRTC //同步当前时间到设备
//{
//    [self reset];
//    NSDate *currentTime = [NSDate date];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yy-MM-EEEE-dd-HH-mm-ss"];
//    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
//    NSString *currentTimeString = [dateFormatter stringFromDate: currentTime];
//    NSLog(@"%@",currentTimeString);
//    
//    NSArray *dateStrings = [currentTimeString componentsSeparatedByString:@"-"];
//    
//    self.WEEKDAYS = [[NSArray alloc] initWithObjects:WEEKDAYARRAY];
//    NSString * weekday = [NSString stringWithFormat: @"%ld", (long)[self.WEEKDAYS indexOfObject:[dateStrings objectAtIndex:2]]];
//    
//    
//    //------ first cmd
//    NSString *cmdFirst = [NSString stringWithFormat:@"%@ %@ %@ 0%@ ", @"S RTC",
//                          [dateStrings objectAtIndex:0],
//                          [dateStrings objectAtIndex:1],
//                          weekday];
//    
//    NSData *dFirst = [cmdFirst dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"%@%@",@"cmd_RTC_First : ",cmdFirst);
//    [self writeValue:_connectedDevice data:dFirst];
//    
//    
//    //------ second cmd
//    NSString *cmdSecond = [NSString stringWithFormat:@"%@ %@ %@ %@", [dateStrings objectAtIndex:3],
//                           [dateStrings objectAtIndex:4],
//                           [dateStrings objectAtIndex:5],
//                           [dateStrings objectAtIndex:6]];
//    
//    
//    cmdSecond = [cmdSecond stringByAppendingFormat:@"%c%c",0x0D,0x0A];
//    NSData *dSecond = [cmdSecond dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"%@%@",@"cmd_RTC_Second : ",cmdSecond);
//    [self writeValue:_connectedDevice data:dSecond];
//    
//    
//}
//@end
