////
////  MPDBluetoothManager.h
////  MicroPort
////
////  Created by FNST on 15/12/15.
////
////
//
//#import <Foundation/Foundation.h>
//#import <CoreBluetooth/CoreBluetooth.h>
//
//#define MPDBluetoothScanResultKey @"peripheral"
//
////from old src s
//#define IMEC_BLE_MODE_SERVICE    0xFFD0
//#define IMEC_BLE_MODE_ENABLER    0xFFD1
//
//
//#define IMEC_BLE_BATTERY_SERVICE 0x180F
//#define IMEC_BLE_BATTERY_LEVEL   0x2A19
//
//#define IMEC_BLE_HR_SERVICE      0x180D
//#define IMEC_BLE_HR_VALUE        0x2A37
//#define IMEC_BLE_HR_VALUE2       0x2A38
//
//#define IMEC_BLE_ECG_SERVICE     0xFFB0
//#define IMEC_BLE_ECG_VALUE       0xFFB1
//
//
//#define IMEC_BLE_ACC_SERVICE     0xFFA0
//#define IMEC_BLE_ACC_VALUE       0xFFA3
//
//#define IMEC_BLE_RES_SERVICE     0xFFC0
//#define IMEC_BLE_RES_VALUE       0xFFC1
//
//#define TI_KEYFOB_PROXIMITY_ALERT_UUID                      0x1802
//#define TI_KEYFOB_PROXIMITY_ALERT_PROPERTY_UUID             0x2a06
//#define TI_KEYFOB_PROXIMITY_ALERT_ON_VAL                    0x01
//#define TI_KEYFOB_PROXIMITY_ALERT_OFF_VAL                   0x00
//#define TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN                 1
//#define TI_KEYFOB_PROXIMITY_TX_PWR_SERVICE_UUID             0x1804
//#define TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_UUID        0x2A07
//#define TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_READ_LEN    1
//
//#define TI_KEYFOB_BATT_SERVICE_UUID                         0x180F
//#define TI_KEYFOB_LEVEL_SERVICE_UUID                        0x2A19
//#define TI_KEYFOB_LEVEL_SERVICE_READ_LEN                    1
//
//#define TI_KEYFOB_ACCEL_SERVICE_UUID                        0xFFA0
//#define TI_KEYFOB_ACCEL_ENABLER_UUID                        0xFFA1
//#define TI_KEYFOB_ACCEL_RANGE_UUID                          0xFFA2
//#define TI_KEYFOB_ACCEL_READ_LEN                            1
//#define TI_KEYFOB_ACCEL_X_UUID                              0xFFA3
//#define TI_KEYFOB_ACCEL_Y_UUID                              0xFFA4
//#define TI_KEYFOB_ACCEL_Z_UUID                              0xFFA5
//
//#define TI_KEYFOB_KEYS_SERVICE_UUID                         0xFFE0
//#define TI_KEYFOB_KEYS_NOTIFICATION_UUID                    0xFFE1
//#define TI_KEYFOB_KEYS_NOTIFICATION_READ_LEN                1
//
////from old src e
//
//@class MPDBluetoothManager;
//
//enum MPDBluetoothMangagerOperationType{
//    MPDBluetoothMangagerOperationType_Scan = 0,
//    MPDBluetoothMangagerOperationType_Connect,
//    MPDBluetoothMangagerOperationType_Read,
//    MPDBluetoothMangagerOperationType_Write
//};
//
//typedef NS_ENUM(NSInteger,MPDeviceCmdType){
//    MPDeviceCmdTypeNone = -1,
//    MPDeviceCmdTypeTypeAllOn=0,
//    MPDeviceCmdTypeTypeAllOff,
//    MPDeviceCmdTypeSetUserName,
//    MPDeviceCmdTypeTypeSDRecordOn,
//    MPDeviceCmdTypeTypeSDRecordOff,
//    MPDeviceCmdTypeTypeSDListFile,
//    MPDeviceCmdTypeTypeSDFormat,
//    MPDeviceCmdTypeTypeSDRecordState,
//    MPDeviceCmdTypeTypeSDTXOn,
//    MPDeviceCmdTypeTypeSDSDTXOff,
//    //mark
//    MPDeviceCmdTypeTypeSDListMark,
//    MPDeviceCmdTypeTypeSDMarkEcg
//};
//typedef NS_ENUM(NSInteger,MPFileType){
//    MPFileTypeNone = -1,
//    MPFileTypeIndexFile=0,
//    MPFileTypeMarkFile
//};
//
//enum MPDBluetoothMangagerOperationResult{
//    MPDBluetoothMangagerOperationResult_Success = 0,
//    MPDBluetoothMangagerOperationResult_Fail
//};
//
//@protocol MPDBluetoothManagerDelegate <NSObject>
//
//@optional
//-(void)bluetoothManager:(MPDBluetoothManager *)manager resultType:(NSInteger)resultType operationType:(NSInteger)operationType resultDic:(NSDictionary *)resultDic msg:(NSString *)msg;
//-(void)deviceReady;
//-(void)fileUpdated:(NSMutableArray *)file type:(NSInteger) type;
//@optional
//-(void) hrValuesUpdated:(int)heartRate;
//-(void) ecgValueUpdated:(uint16_t)ECG;
//-(void) ecgValuesUpdated:(NSMutableArray *)ECG;
//-(void) accValuesUpdated:(int)accX y:(int)accY z:(int)accZ;
//-(void) batteryValuesUpdated:(float)battery;
//-(void) connectionValuesUpdated:(float)battery;
//
//-(void) statusUpdated:(NSString*)status left:(NSInteger)leftHour;
//-(void) fileUpdated:(NSMutableArray*)file;
//
//@end
//
//@interface MPDBluetoothManager : NSObject
//@property (weak,nonatomic) id delegate;
//@property (nonatomic, assign) BOOL forceClose;
//@property (nonatomic) CBPeripheral *connectedDevice;
//@property (nonatomic) NSMutableArray *discoverdPeriparals;
//@property (nonatomic) NSMutableArray *sdFlieList;
//@property (nonatomic) BOOL shouldContinueScan;
//@property (nonatomic) BOOL shouldScan; //扫描状态
//
//+(MPDBluetoothManager *)sharedManager;
//-(void)scanForDevices;
//-(void)connectToDevice:(CBPeripheral *)peripheral;
//-(void)disconnectCurrentDevice;
//-(void)disconnectToDevice:(CBPeripheral *)peripheral;
////-(void)startReadEcgData:(CBPeripheral *)peripheral;
//-(void)stopScan;
//-(void)startReadEcgData;
//-(void)stopReadEcgData;
//-(void)stopCurrentWork;
////mark
//-(void)startReadMarkEcg:(NSInteger)index;
//-(void)startReadMarkList;
//-(void)startReadSDFileList;
//-(void)startSDFormat;
////
//-(void)setUsername:(NSString *)name;
//-(void)getSDRecordState;
//-(void)startSDRecord:(NSString *)duration peripheral:(CBPeripheral *)p;
//-(void)stopSDRecord;
//-(void)setRTC;
//-(void)listSDFile;
////-(void)formatSDCard;
//-(void)cmdSDTX_OFF_After:(MPDeviceCmdType) afterOff;
//-(void)cmdSDTX_ON_After:(MPDeviceCmdType) afterOn;
////
//-(CBPeripheral *)getCurrentConnectedDevice;
//-(void)connectToDefaultDevice;
//-(BOOL)hasDeviceConnected;
////-(NSString *)getCurrentDevice;
//-(NSString *)getCurrentDeviceName;
//
////-(void)readSDFile;
//@end
