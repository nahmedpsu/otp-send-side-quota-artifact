| group | design | N | L | T | faults | F | replication | property | verdict | distinct states | trace states | seconds |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| H0 | ConditionalUpdate | 3 | 1 | 4 | False | 0 | asynchronous | C1tau | violated | 10111 | 11 | 2.1 |
| H0 | ConditionalUpdateDb | 3 | 2 | 4 | False | 0 | asynchronous | C1 | holds | 215618 |  | 3.6 |
| H0 | ReserveBeforeSendDb | 3 | 1 | 4 | True | 0 | asynchronous | C2 | holds | 6226156 |  | 38.4 |
| H | ConditionalUpdate | 2 | 1 | 4 | False | 1 | asynchronous | C1 | violated | 7957 | 10 | 1.6 |
| H | ConditionalUpdate | 2 | 1 | 4 | False | 1 | asynchronous | C1F | holds | 65659 |  | 1.6 |
| H | ConditionalUpdate | 2 | 1 | 4 | False | 1 | asynchronous | C1tau | violated | 7367 | 10 | 1.7 |
| H | ConditionalUpdate | 2 | 1 | 4 | False | 1 | asynchronous | C1tauF | holds | 65659 |  | 1.7 |
| H | ConditionalUpdate | 3 | 1 | 4 | False | 1 | asynchronous | C1 | violated | 29653 | 10 | 2.5 |
| H | ConditionalUpdate | 3 | 1 | 4 | False | 1 | asynchronous | C1F | holds | 3818809 |  | 24.0 |
| H | ConditionalUpdate | 3 | 1 | 4 | False | 1 | asynchronous | C1tau | violated | 27838 | 10 | 2.7 |
| H | ConditionalUpdate | 3 | 1 | 4 | False | 1 | asynchronous | C1tauF | violated | 607948 | 16 | 15.7 |
| H | ConditionalUpdate | 3 | 2 | 4 | False | 1 | asynchronous | C1 | violated | 431123 | 14 | 7.8 |
| H | ConditionalUpdate | 3 | 2 | 4 | False | 1 | asynchronous | C1F | holds | 8152264 |  | 47.6 |
| H | ConditionalUpdate | 3 | 2 | 4 | False | 1 | asynchronous | C1tau | violated | 370139 | 14 | 8.7 |
| H | ConditionalUpdate | 3 | 2 | 4 | False | 1 | asynchronous | C1tauF | holds | 8152264 |  | 48.5 |
| H | ConditionalUpdateDb | 2 | 1 | 4 | False | 1 | asynchronous | C1 | violated | 992 | 6 | 1.4 |
| H | ConditionalUpdateDb | 2 | 1 | 4 | False | 1 | asynchronous | C1F | holds | 27449 |  | 1.3 |
| H | ConditionalUpdateDb | 2 | 1 | 4 | False | 1 | asynchronous | C1tau | violated | 774 | 6 | 1.5 |
| H | ConditionalUpdateDb | 2 | 1 | 4 | False | 1 | asynchronous | C1tauF | holds | 27449 |  | 1.2 |
| H | ConditionalUpdateDb | 3 | 1 | 4 | False | 1 | asynchronous | C1 | violated | 1563 | 6 | 1.5 |
| H | ConditionalUpdateDb | 3 | 1 | 4 | False | 1 | asynchronous | C1F | holds | 1077109 |  | 9.2 |
| H | ConditionalUpdateDb | 3 | 1 | 4 | False | 1 | asynchronous | C1tau | violated | 1234 | 6 | 1.3 |
| H | ConditionalUpdateDb | 3 | 1 | 4 | False | 1 | asynchronous | C1tauF | holds | 1077109 |  | 9.6 |
| H | ConditionalUpdateDb | 3 | 2 | 4 | False | 1 | asynchronous | C1 | violated | 12206 | 8 | 2.0 |
| H | ConditionalUpdateDb | 3 | 2 | 4 | False | 1 | asynchronous | C1F | holds | 2295493 |  | 16.1 |
| H | ConditionalUpdateDb | 3 | 2 | 4 | False | 1 | asynchronous | C1tau | violated | 10288 | 8 | 2.0 |
| H | ConditionalUpdateDb | 3 | 2 | 4 | False | 1 | asynchronous | C1tauF | holds | 2295493 |  | 16.3 |
| H | ReserveBeforeSendDb | 2 | 1 | 4 | True | 1 | asynchronous | C1 | violated | 1768 | 6 | 1.3 |
| H | ReserveBeforeSendDb | 2 | 1 | 4 | True | 1 | asynchronous | C1F | holds | 611584 |  | 4.8 |
| H | ReserveBeforeSendDb | 2 | 1 | 4 | True | 1 | asynchronous | C1tau | violated | 1402 | 6 | 1.3 |
| H | ReserveBeforeSendDb | 2 | 1 | 4 | True | 1 | asynchronous | C1tauF | holds | 611584 |  | 5.5 |
| H | ReserveBeforeSendDb | 2 | 1 | 4 | True | 1 | asynchronous | C2 | violated | 9379 | 8 | 1.8 |
| H | ReserveBeforeSendDb | 2 | 1 | 4 | True | 1 | asynchronous | C2F | holds | 611584 |  | 5.2 |
| H | ReserveBeforeSendDb | 2 | 1 | 4 | True | 1 | asynchronous | NonNegative | violated | 48599 | 10 | 2.4 |
| H | ReserveBeforeSendDb | 3 | 1 | 4 | True | 1 | asynchronous | C1 | violated | 2033 | 6 | 1.4 |
| H | ReserveBeforeSendDb | 3 | 1 | 4 | True | 1 | asynchronous | C1F | violated | 219013 | 10 | 4.6 |
| H | ReserveBeforeSendDb | 3 | 1 | 4 | True | 1 | asynchronous | C1tau | violated | 1743 | 6 | 1.4 |
| H | ReserveBeforeSendDb | 3 | 1 | 4 | True | 1 | asynchronous | C1tauF | violated | 208373 | 10 | 5.0 |
| H | ReserveBeforeSendDb | 3 | 1 | 4 | True | 1 | asynchronous | C2 | violated | 26564 | 8 | 2.4 |
| H | ReserveBeforeSendDb | 3 | 1 | 4 | True | 1 | asynchronous | C2F | holds | 92341641 |  | 590.7 |
| H | ReserveBeforeSendDb | 3 | 1 | 4 | True | 1 | asynchronous | NonNegative | violated | 245558 | 10 | 4.2 |
| H | ConditionalUpdate | 2 | 1 | 4 | False | 1 | synchronous | C1 | holds | 11340 |  | 0.9 |
| H | ConditionalUpdate | 2 | 1 | 4 | False | 1 | synchronous | C1F | holds | 11340 |  | 1.0 |
| H | ConditionalUpdate | 2 | 1 | 4 | False | 1 | synchronous | C1tau | violated | 4070 | 11 | 1.5 |
| H | ConditionalUpdate | 2 | 1 | 4 | False | 1 | synchronous | C1tauF | holds | 11340 |  | 1.1 |
| H | ConditionalUpdate | 3 | 1 | 4 | False | 1 | synchronous | C1 | holds | 425242 |  | 4.2 |
| H | ConditionalUpdate | 3 | 1 | 4 | False | 1 | synchronous | C1F | holds | 425242 |  | 3.7 |
| H | ConditionalUpdate | 3 | 1 | 4 | False | 1 | synchronous | C1tau | violated | 19325 | 11 | 2.2 |
| H | ConditionalUpdate | 3 | 1 | 4 | False | 1 | synchronous | C1tauF | violated | 187997 | 17 | 6.6 |
| H | ConditionalUpdate | 3 | 2 | 4 | False | 1 | synchronous | C1 | holds | 860596 |  | 7.0 |
| H | ConditionalUpdate | 3 | 2 | 4 | False | 1 | synchronous | C1F | holds | 860596 |  | 6.9 |
| H | ConditionalUpdate | 3 | 2 | 4 | False | 1 | synchronous | C1tau | violated | 151795 | 15 | 5.1 |
| H | ConditionalUpdate | 3 | 2 | 4 | False | 1 | synchronous | C1tauF | holds | 860596 |  | 7.1 |
| H | ConditionalUpdateDb | 2 | 1 | 4 | False | 1 | synchronous | C1 | holds | 7900 |  | 0.9 |
| H | ConditionalUpdateDb | 2 | 1 | 4 | False | 1 | synchronous | C1F | holds | 7900 |  | 0.9 |
| H | ConditionalUpdateDb | 2 | 1 | 4 | False | 1 | synchronous | C1tau | holds | 7900 |  | 0.9 |
| H | ConditionalUpdateDb | 2 | 1 | 4 | False | 1 | synchronous | C1tauF | holds | 7900 |  | 1.0 |
| H | ConditionalUpdateDb | 3 | 1 | 4 | False | 1 | synchronous | C1 | holds | 219718 |  | 2.6 |
| H | ConditionalUpdateDb | 3 | 1 | 4 | False | 1 | synchronous | C1F | holds | 219718 |  | 2.8 |
| H | ConditionalUpdateDb | 3 | 1 | 4 | False | 1 | synchronous | C1tau | holds | 219718 |  | 2.8 |
| H | ConditionalUpdateDb | 3 | 1 | 4 | False | 1 | synchronous | C1tauF | holds | 219718 |  | 2.6 |
| H | ConditionalUpdateDb | 3 | 2 | 4 | False | 1 | synchronous | C1 | holds | 431236 |  | 4.0 |
| H | ConditionalUpdateDb | 3 | 2 | 4 | False | 1 | synchronous | C1F | holds | 431236 |  | 4.0 |
| H | ConditionalUpdateDb | 3 | 2 | 4 | False | 1 | synchronous | C1tau | holds | 431236 |  | 4.2 |
| H | ConditionalUpdateDb | 3 | 2 | 4 | False | 1 | synchronous | C1tauF | holds | 431236 |  | 4.0 |
| H | ReserveBeforeSendDb | 2 | 1 | 4 | True | 1 | synchronous | C1 | violated | 2281 | 7 | 1.3 |
| H | ReserveBeforeSendDb | 2 | 1 | 4 | True | 1 | synchronous | C1F | holds | 136190 |  | 2.0 |
| H | ReserveBeforeSendDb | 2 | 1 | 4 | True | 1 | synchronous | C1tau | violated | 2556 | 7 | 1.3 |
| H | ReserveBeforeSendDb | 2 | 1 | 4 | True | 1 | synchronous | C1tauF | holds | 136190 |  | 2.3 |
| H | ReserveBeforeSendDb | 2 | 1 | 4 | True | 1 | synchronous | C2 | holds | 136190 |  | 2.2 |
| H | ReserveBeforeSendDb | 2 | 1 | 4 | True | 1 | synchronous | C2F | holds | 136190 |  | 2.4 |
| H | ReserveBeforeSendDb | 2 | 1 | 4 | True | 1 | synchronous | NonNegative | holds | 136190 |  | 1.9 |
| H | ReserveBeforeSendDb | 3 | 1 | 4 | True | 1 | synchronous | C1 | violated | 5617 | 7 | 1.5 |
| H | ReserveBeforeSendDb | 3 | 1 | 4 | True | 1 | synchronous | C1F | violated | 417179 | 11 | 6.2 |
| H | ReserveBeforeSendDb | 3 | 1 | 4 | True | 1 | synchronous | C1tau | violated | 5022 | 7 | 1.4 |
| H | ReserveBeforeSendDb | 3 | 1 | 4 | True | 1 | synchronous | C1tauF | violated | 427233 | 11 | 7.0 |
| H | ReserveBeforeSendDb | 3 | 1 | 4 | True | 1 | synchronous | C2 | holds | 12452312 |  | 76.3 |
| H | ReserveBeforeSendDb | 3 | 1 | 4 | True | 1 | synchronous | C2F | holds | 12452312 |  | 74.9 |
| H | ReserveBeforeSendDb | 3 | 1 | 4 | True | 1 | synchronous | NonNegative | holds | 12452312 |  | 68.5 |
