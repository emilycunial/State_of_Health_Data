function [lock1,lock2,lock1_max,lock2_max] = lockstat(lock_status,len)

lock1 = zeros(1,len); %vector to store the time it has been since lock = 2 (locked)
lock2 = zeros(1,len); %vector to store the time it has been since lock = 1 or = 2 (on)

lock1_max = zeros(1,len); %vector to store the max time since a lock = 2 (data point before a 0)
lock2_max = zeros(1,len); %vector to store the max time since a lock = 1 or =2 (data point before a 0)

%% Time Since Lock Status = 2
counter = 0;
for i = 1:len
    if lock_status(i) == 0
        counter = counter + 1;
    elseif lock_status(i) == 1
        counter = counter + 1;
    elseif lock_status(i) == 2
        counter = 0;
    end
    lock1(i) = counter; %store the value of counter after every loop into a vector
end

for j = 2:len
    if lock1(j) == 0
        lock1_max(j-1) = lock1(j-1);
    else
        lock1_max(j-1) = 0;
    end
end


%% Time Since Lock Status = 1 or 2
counter = 0;
for i = 1:len
    if lock_status(i) == 0
        counter = counter + 1;
    elseif lock_status(i) == 1
        counter = counter + 1;
    elseif lock_status(i) == 2
        counter = 0;
    end
    lock2(i) = counter; %store the value of counter after every loop into a vector
end

for j = 2:len
    if lock2(j) == 0
        lock2_max(j-1) = lock2(j-1);
    else
        lock2_max(j-1) = 0;
    end
end

