sed -i 's/        abort(); \/\/ Force crash to safe mode/        \/\/ abort(); \/\/ Removed abort to prevent SpringBoard bootloops due to lazy framework loading/g' /app/RoundCC/Tweak.x
