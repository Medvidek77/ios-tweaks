sed -i 's/NSLog(@"\[RoundCC\]/#ifdef DEBUG\n    NSLog(@"\[RoundCC\]/g' /app/RoundCC/Tweak.x
sed -i 's/!= nil);/!= nil);\n#endif/g' /app/RoundCC/Tweak.x
