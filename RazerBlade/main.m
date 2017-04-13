//
//  main.m
//  RazerBlade
//
//  Created by Kishor Prins on 2017-04-12.
//  Copyright © 2017 Kishor Prins. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "razerkbd_driver.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        //NSLog(@"Hello, World!");
        
        CFMutableDictionaryRef matchingDict;
        io_iterator_t iter;
        kern_return_t kr;
        io_service_t usbDevice;
        
        /* set up a matching dictionary for the class */
        matchingDict = IOServiceMatching(kIOUSBDeviceClassName);
        if (matchingDict == NULL) {
            return -1; // fail
        }
        
        /* Now we have a dictionary, get an iterator.*/
        kr = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &iter);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        /* iterate */
        while ((usbDevice = IOIteratorNext(iter))) {
            kern_return_t kr;
            IOCFPlugInInterface **plugInInterface = NULL;
            SInt32 score;
            HRESULT result;
            IOUSBDeviceInterface **dev = NULL;
            
            UInt16 vendor;
            UInt16 product;
            UInt16 release;
            
            kr = IOCreatePlugInInterfaceForService(usbDevice, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score);
            
            //Don’t need the device object after intermediate plug-in is created
            kr = IOObjectRelease(usbDevice);
            if ((kIOReturnSuccess != kr) || !plugInInterface) {
                printf("Unable to create a plug-in (%08x)\n", kr);
                continue;
                
            }
            
            //Now create the device interface
            result = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID), (LPVOID *)&dev);
            
            //Don’t need the intermediate plug-in after device interface is created
            (*plugInInterface)->Release(plugInInterface);
            
            if (result || !dev) {
                printf("Couldn’t create a device interface (%08x)\n",
                       (int) result);
                continue;
                
            }
            
            //Check these values for confirmation
            kr = (*dev)->GetDeviceVendor(dev, &vendor);
            kr = (*dev)->GetDeviceProduct(dev, &product);
            kr = (*dev)->GetDeviceReleaseNumber(dev, &release);
            
            if ((vendor != USB_VENDOR_ID_RAZER) || (product != USB_DEVICE_ID_RAZER_BLADE_STEALTH_LATE_2016)) {
                (void) (*dev)->Release(dev);
                continue;
            }
            
            //Open the device to change its state
            kr = (*dev)->USBDeviceOpen(dev);
            if (kr != kIOReturnSuccess)  {
                printf("Unable to open device: %08x\n", kr);
                (void) (*dev)->Release(dev);
                continue;
                
            }
            
            razer_attr_write_mode_starlight(dev, NULL, -1);
            
            //Close this device and release object
            kr = (*dev)->USBDeviceClose(dev);
            kr = (*dev)->Release(dev);
        }
        
        /* Done, release the iterator */
        IOObjectRelease(iter);
        return 0;
    }
    
    return 0;
}
