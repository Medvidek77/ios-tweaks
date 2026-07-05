sed -i 's/static NSString \*moduleColorHex = @"";/static NSString \*moduleColorHex = @"";\nstatic UIColor \*parsedModuleColor = nil;/g' /app/RoundCC/Tweak.x
sed -i 's/unsigned int baseValue;/unsigned int baseValue = 0;/g' /app/RoundCC/Tweak.x
sed -i 's/moduleColorHex = \[prefs objectForKey:@"moduleColor"\] ? \[prefs objectForKey:@"moduleColor"\] : @"";/moduleColorHex = \[prefs objectForKey:@"moduleColor"\] ? \[prefs objectForKey:@"moduleColor"\] : @"";\n        parsedModuleColor = colorFromHexString(moduleColorHex);/g' /app/RoundCC/Tweak.x
sed -i 's/UIColor \*customColor = colorFromHexString(moduleColorHex);/UIColor \*customColor = parsedModuleColor;/g' /app/RoundCC/Tweak.x
