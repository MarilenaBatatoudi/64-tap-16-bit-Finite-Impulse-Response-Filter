function y = fir_filter(x, b)
    % FIR filter function
    % Parameter x denotes the input signal
    % Parameter b denotes the filter coefficients
    % y corresponds to the output signal after applying the fir filter

    N = length(b); % Filter order
    L = length(x); % Length of input signal
    y = zeros(1, L); % Initialize output array to all 0

    for n = 1:L
        % Convolution operation for fir filter
        for k = 1:N
            if n - k + 1 > 0
                y(n) = y(n) + b(k) * x(n - k + 1);
            end
        end
    end
end
