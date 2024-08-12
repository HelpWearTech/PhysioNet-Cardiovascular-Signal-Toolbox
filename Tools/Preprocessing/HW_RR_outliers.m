function [no_outliers, number_removed] = HW_RR_outliers(RRI_intervals, OUTLIER_THRESH)
    arguments (Input)
        RRI_intervals (:, 1)
        OUTLIER_THRESH (1,1) = 0.20 % 20% default
    end
    % USAGE NOTE:
    % `number_removed` will count the number of intervals removed due to
    % deviation from the median interval length; 
    % It will not count the "first-pass" removal of unphysiological
    % intervals (way too short or way too long). Those are more likely due
    % to measurement/processing error/data quality issues.
    intervals_workingcopy = RRI_intervals;

    % * first one is conventionally zero (no "preceding interval" for first
    % beat ).
    unphys_limit_high = 3.00; % sec
    unphys_limit_low  = 0.15; % sec

    unphysiological_binary = (RRI_intervals < unphys_limit_low) | (RRI_intervals > unphys_limit_high);
    intervals_workingcopy(unphysiological_binary) = nan;

    % compute moving median among VALID beats, then re-insert the NaN's
    % into the "median signal".
    valid_intervals_sofar = intervals_workingcopy(~isnan(intervals_workingcopy)); % ** SHORTER
    medsignal_validonly = movmedian(valid_intervals_sofar , 9); % ** SHORTER
    medsignal_reinserted = nan(size(intervals_workingcopy));
    medsignal_reinserted(~isnan(intervals_workingcopy)) = medsignal_validonly;
    
    % comparison against the re-inserted nans will always be False, but it
    % doesnt matter because we already nanned those intervals.
    outliers_sense = abs(intervals_workingcopy - medsignal_reinserted) ./ medsignal_reinserted;

    these_are_outliers = outliers_sense > OUTLIER_THRESH; % 20% is default
    intervals_workingcopy(these_are_outliers) = nan;

    % Send outputs
    no_outliers = intervals_workingcopy;
    number_removed = sum(these_are_outliers);
end