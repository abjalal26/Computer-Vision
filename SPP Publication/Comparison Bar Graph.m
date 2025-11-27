%% data horizontal bar graph

g = [3790403.4 5927526.15; 3145602.55 3345517.2; 3493168.2 3868128.5;
    6204973.5 8687687.35; 1942639.95 2040517.5];
barh(g)
xlabel("Average Registration Area (px)")
ax = gca;
ax.YTick = [1,2,3,4,5];
ax.YTickLabel = {'Airport (2013) - wide','Capyas (2015) - wide',
    'White (2013) - wide','Talipanan (2013) - wide','Calatagan (2024) - medium'};
set(gca,"FontSize",14);
sd = [93979.87426 871864.402 61718.53039 54883.59213 185131.7203
    134184.8724 1720084.201 2679782.294 69706.36016 98796.75015];
y = [0.86 1.14 1.86 2.14 2.86 3.14 3.86 4.14 4.86 5.14];
x = [3790403.4 5927526.15 3145602.55 3345517.2 3493168.2 3868128.5 6204973.5 8687687.35 1942639.95 2040517.5];
hold on
e = errorbar(x,y,sd, 'horizontal', "LineStyle","none", "LineWidth", 2.5)
e.CapSize = 12
legend('cropped','undistorted', 'SD')