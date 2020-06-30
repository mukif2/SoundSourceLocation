%% MVDR, speech, different noise
RMSE = [0.3673, 0.3860, 0.4460, 0.4423, 0.4147;...
        0.2889, 0.2262, 0.2747, 0.2303, 0.2128;...
        0.5108, 0.4735, 0.3710, 0.3879, 0.4065;
        1.5263, 1.4980, 1.5354, 1.5513, 1.5433];

rate = [80.21,  79.17,  79.69,  73.61,  75.00;...
        79.69,  79.69,  83.33,  87.50,  87.50;...
        59.38,  45.83,  54.17,  59.72,  61.46;...
        0.00,   0.00,   0.00,   0.00,   0.00];
    
figure;
plot(RMSE, 'LineWidth', 2);
set(gca, 'XTick', [1,2,3,4]);
xlabel('SNR group');
ylabel('RMSE');
l = legend('free-flight', 'hovering', 'rectangle', 'spinning', 'updown',...
        'Location', 'northwest');
set(l, 'FontSize', 12);

figure;
plot(rate, 'LineWidth', 2);
set(gca, 'XTick', [1,2,3,4]);
xlabel('SNR group');
ylabel('accept rate');
l = legend('free-flight', 'hovering', 'rectangle', 'spinning', 'updown',...
        'Location', 'southwest');
set(l, 'FontSize', 12);

%% MVDR, different source
RMSE = [0.4124, 0.3809, 1.1965;...
        0.2484, 0.1245, 0.9150;...
        0.4332, 1.1457, 1.1259;
        1.5310, 1.5460, 1.5473];

rate = [77.48,  87.82,  16.49;...
        83.54,  95.20,  20.93;...
        56.11,  30.31,  11.99;...
        0.00,   0.00,   0.00];
    
figure;
plot(RMSE, 'LineWidth', 2);
set(gca, 'XTick', [1,2,3,4]);
xlabel('SNR group');
ylabel('RMSE');
l = legend('speech', 'whitenoise', 'chirps',...
        'Location', 'northwest');
set(l, 'FontSize', 12);

figure;
plot(rate, 'LineWidth', 2);
set(gca, 'XTick', [1,2,3,4]);
xlabel('SNR group');
ylabel('accept rate');
l = legend('speech', 'whitenoise', 'chirps',...
        'Location', 'northeast');
set(l, 'FontSize', 12);