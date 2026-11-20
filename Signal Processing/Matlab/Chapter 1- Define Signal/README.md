# Continuous- and discrete-time signal representations

This MATLAB script plots eight elementary signal families in continuous time and eight corresponding discrete-time examples. It is a visualization exercise: it does not fit a signal model, process an experimental recording, or report prediction accuracy.

The source is [`Project1_CDSignals.m`](Project1_CDSignals.m). It explicitly defines the time vectors and all signal expressions before generating a single figure with 16 subplots.

## Signals shown

| Signal | Continuous-time definition in the script | Discrete-time definition in the script |
|---|---|---|
| Unit step | `u(t) = [t >= 0]` | `u[n] = [n >= 0]` |
| Impulse | finite-width rectangular approximation centered at zero | Kronecker delta `[n == 0]` |
| Rectangular pulse | `[-0.5,0.5]` indicator | `[-5,5]` indicator |
| Sinusoid | `sin(2*pi*5*t)` | `sin(2*pi*2*n/10)` |
| Exponential | `exp(-5*t)` | `exp(-0.05*n)` |
| Triangle | `sawtooth(2*pi*5*t,0.5)` | `sawtooth(2*pi*2*n/10,0.5)` |
| Sawtooth | `sawtooth(2*pi*5*t)` | `sawtooth(2*pi*2*n/10)` |
| Normalized sinc | `sinc(t)` | `sinc(n/10)` |

The continuous-time display samples `t=-1:0.001:1`. The discrete-time examples use `n=-10:10`, with a sampling frequency `Fs=10` and a sinusoid at `2 Hz`—below the `5 Hz` Nyquist frequency. This avoids the earlier example in which sampling a sinusoid at an inappropriate frequency made the discrete sequence misleading.

For the continuous impulse illustration, the code sets `q(t)=[|t|<=0.01]` at the sampled time points and normalizes by its **numerically sampled area**:

```text
delta_approx(t_i) = q(t_i) / [sum_i q(t_i) * Delta_t].
```

It has unit discrete numerical area under the chosen grid; it is not the mathematical Dirac distribution. The discrete impulse is the exact Kronecker delta on the displayed integer samples.

The exponential signals are examples on their respective finite plotting intervals, not asserted to be decaying on all `t` or `n`: the expressions become large when their arguments are sufficiently negative.

## Run

Use MATLAB R2024a with Signal Processing Toolbox for `sawtooth` and `sinc`. Open this folder in MATLAB and run:

```matlab
Project1_CDSignals
```

The result is a single 4-by-4 figure: continuous-time plots in the first two rows and discrete-time stem plots in the last two. The script adjusts root graphics defaults, docks figures, closes other figures, clears variables and disables warnings. Those are **session-wide side effects**, so a separate MATLAB session is preferable if you are also working with figures from other experiments.

## Validation and limits

The numerical regression suite checks specific sampled-signal properties, including the non-degenerate discrete sinusoid and the finite-pulse area normalization. It does not constitute automated pixel-for-pixel validation of the 16-plot figure, nor has a research dataset been analyzed with these demonstrations.

The purpose of the project is to make the discrete/continuous distinction explicit through reproducible mathematical expressions and visible sampling. It should be presented as a signal-processing exercise rather than an electrophysiology result.
