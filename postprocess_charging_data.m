% Author: Mark Gottscho
% mgottscho@ucla.edu
%
% Make sure to run pre_process_charging_data.m script first, or otherwise
% load in the saved .mat file from that script.

%% Set up paths for pre-processed, processed, and output
master_path = '/Users/Mark/Dropbox/AvailabilityAware-share/data/charging/';

pre_processed_data_path = [master_path 'pre-processed/'];
nexus4_pre_processed_data_path = [pre_processed_data_path 'nexus4/'];
ipod_pre_processed_data_path = [pre_processed_data_path 'ipod/'];
custom_pre_processed_data_path = [pre_processed_data_path 'custom/'];
rawbatt_pre_processed_data_path = [pre_processed_data_path 'rawbatt/'];

post_processed_data_path = [master_path 'post-processed/'];
nexus4_post_processed_data_path = [post_processed_data_path 'nexus4/'];
ipod_post_processed_data_path = [post_processed_data_path 'ipod/'];
custom_post_processed_data_path = [post_processed_data_path 'custom/'];
rawbatt_post_processed_data_path = [post_processed_data_path 'rawbatt/'];

%% Post-process Nexus4 traces (filter out end-of-charge noise from phone turning on)

% Fix the 300mA and 400mA runs
% For these particular sets of data, everything after initial charging cutoff
% should be the same baseline as the other higher power charging runs
nexus4_trace_5V_300mA_fixed = nexus4_trace_5V_300mA;
nexus4_trace_5V_300mA_fixed(65410:size(nexus4_trace_5V_300mA_fixed,1),3) = 0.0252;

nexus4_trace_5V_400mA_fixed = nexus4_trace_5V_400mA;
nexus4_trace_5V_400mA_fixed(54476:size(nexus4_trace_5V_400mA_fixed,1),3) = 0.0252;

%% Aggregate & plot post-processed Nexus4 traces
nexus4_max_S = 90000; % Change me, I am a hack
nexus4_num_traces = 5; % Change me, I am a hack
nexus4_traces = NaN(nexus4_max_S, 3, nexus4_num_traces);

% Skip raw nexus4 low current traces since they needed end-of-charge fix
%nexus4_traces(:,:,1) = nexus4_trace_5V_300mA;
nexus4_traces(:,:,1) = nexus4_trace_5V_300mA_fixed;
% Skip raw nexus4 low current traces since they needed end-of-charge fix
%nexus4_traces(:,:,2) = nexus4_trace_5V_400mA;
nexus4_traces(:,:,2) = nexus4_trace_5V_400mA_fixed;
nexus4_traces(:,:,3) = nexus4_trace_5V_600mA;
nexus4_traces(:,:,4) = nexus4_trace_5V_700mA;
nexus4_traces(:,:,5) = nexus4_trace_5V_1000mA;
% Skip 2100mA since not interesting
%nexus4_traces(:,:,6) = nexus4_trace_5V_2100mA;

nexus4_labels = {  'Nexus4, 5V, 300mA Limit -- Fixed'...
            'Nexus4, 5V, 400mA Limit -- Fixed'...
            'Nexus4, 5V, 600mA Limit With USB Limit Removed'...
            'Nexus4, 5V, 700mA Limit With USB Limit Removed'...
            'Nexus4, 5V, 1000mA Limit With USB Limit Removed'...
            %'Nexus4, 5V, 2100mA Limit With USB Limit Removed'...
         };

plot_charging_data(nexus4_traces, hsv(nexus4_num_traces), nexus4_labels, 'Nexus4', nexus4_post_processed_data_path);

%% Post-process iPod traces (filter out noise from iPod accidentally being on during charging)

% Fix the 500 mA run
ipod_trace_5V_500mA_fixed = ipod_trace_5V_500mA;
ipod_trace_5V_500mA_fixed(1336:1920,3) = 0.4980;

% Fix 1000mA run
ipod_smoothing_winSize = 512;
ipod_trace_5V_1000mA_fixed = NaN(floor(size(ipod_trace_5V_1000mA, 1) / ipod_smoothing_winSize), 3);

% Calculate the average samples in new trace
for i = 1 : size(ipod_trace_5V_1000mA_fixed,1)
    ipod_trace_5V_1000mA_fixed(i,1) = ipod_trace_5V_1000mA((i-1)*ipod_smoothing_winSize+1, 1); % Copy over timestamp for every winSize samples
    ipod_trace_5V_1000mA_fixed(i,2) = mean(ipod_trace_5V_1000mA((i-1)*ipod_smoothing_winSize+1:1:i*ipod_smoothing_winSize, 2)); % Compute average voltage over the window
    ipod_trace_5V_1000mA_fixed(i,3) = mean(ipod_trace_5V_1000mA((i-1)*ipod_smoothing_winSize+1:1:i*ipod_smoothing_winSize, 3))+0.015; % Compute average current over the window
end

%% Aggregate & plot post-processed iPod traces
ipod_max_S = 90000; % Change me, I am a hack
ipod_num_traces = 2; % Change me, I am a hack
ipod_traces = NaN(ipod_max_S, 3, ipod_num_traces);

% Skip raw iPod traces since they needed fixing
%ipod_traces(:,:,1) = ipod_trace_5V_500mA;
ipod_traces(:,:,1) = ipod_trace_5V_500mA_fixed;
% Skip raw iPod traces since they needed fixing
%ipod_traces(:,:,2) = ipod_trace_5V_1000mA;
ipod_traces(1:size(ipod_trace_5V_1000mA_fixed,1),:,2) = ipod_trace_5V_1000mA_fixed;

ipod_labels = {  'iPod Touch 5th Gen, 5V, 500mA Limit With USB Limit Removed -- Fixed'...
                 'iPod Touch 5th Gen, 5V, 1000mA Limit With USB Limit Removed -- Fixed'...
         };

plot_charging_data(ipod_traces, hsv(ipod_num_traces), ipod_labels, 'iPod Touch 5th Gen', ipod_post_processed_data_path);


%% Aggregate & plot Custom mbed-generated pre-processed traces with the instrumentation board
custom_max_S = 13238; % Change me, I am a hack
custom_num_traces = 1; % Change me, I am a hack
custom_traces = NaN(custom_max_S, 3, custom_num_traces);

custom_traces(:,:,1) = custom_trace_5V_500mA_battery;
custom_traces(:,3,:) = -custom_traces(:,3,:); % Flip current polarity to plot, since negative current for battery on custom board means charging

custom_labels = {  'Custom Board, 5V, 500mA Limit'...
         };

plot_charging_data(custom_traces, hsv(custom_num_traces), custom_labels, 'Custom Board', custom_post_processed_data_path);

% Plot the battery SOC custom since it's not expected format for
% plot_charging_data()
figure;
plot(custom_trace_5V_500mA_battsoc(:,1)/3600, custom_trace_5V_500mA_battsoc(:,2));
xlabel('Time (h)', 'FontName', 'Arial', 'FontSize', 16);
ylabel('Battery State of Charge (%)', 'FontName', 'Arial', 'FontSize', 16);
title('Custom Board', 'FontName', 'Arial', 'FontSize', 18);
saveplot(gcf, [custom_post_processed_data_path 'charging_soc']);


%% Aggregate & plot direct pre-processed battery traces
rawbatt_max_S = 72000; % Change me, I am a hack
rawbatt_num_traces = 1; % Change me, I am a hack
rawbatt_traces = NaN(rawbatt_max_S, 3, rawbatt_num_traces);

rawbatt_traces(:,:,1) = rawbatt_400mAh_trace_4200mV_500mA;

rawbatt_labels = {  'Raw 400mAh Battery, 4.2V, 500mA Limit'...
         };

plot_charging_data(rawbatt_traces, hsv(rawbatt_num_traces), rawbatt_labels, 'Direct LiPo 400mAh Battery', rawbatt_post_processed_data_path);

%% Save post-processed workspace, which includes pre-processed data as well
save([post_processed_data_path 'post-processed.mat'], '-v7.3');

%% Organize figures on screen
tilefig;