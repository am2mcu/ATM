/*
Armin Mazloumi :)

Project Extra options:
    1. checking card's expiration date
    2. checking password
    3. changing password
    4. recieving account report
    5. banning account for entering 3 wrong password
    6. unban service

Operations:
    1. show balance
    2. withdraw money
    3. tranfer money
    4. account report
    5. change password
    6. unban account

State:
    0. Main Menu
    7. Waiting for cards
*/

`define current_date 11'd2022 // 2022 is 11 bits in binary
`define minimum_balance 10'd100
`define unban_cost 10'd100

module ATM_test();
    reg clock;
    reg [9:0] credit_number, destination, withdraw, password, new_password;
    reg [10:0] expiration_date;
    reg [2:0] operation;
    reg exit;
    wire card_declined;

    ATM ATM(clock, credit_number, destination, withdraw, expiration_date, password, new_password, operation, exit, card_declined);

    initial begin
        clock = 1;

        // entering destination card before source (operation isn't allowed)
        #10
        destination = 10'd100;
        expiration_date = 11'd2024;
        operation = 3'b001;
        clock = ~clock;
        clock = ~clock;

        // entering an expired card
        #10
        credit_number = 10'd500;
        expiration_date = 11'd2020;
        operation = 3'b001;
        clock = ~clock;
        clock = ~clock;

        // providing wrong password
        #10
        password = 10'd501;
        expiration_date = 11'd2023;
        operation = 3'b001;
        clock = ~clock;
        clock = ~clock;

        // correcting the password
        #10
        password = 10'd500;
        clock = ~clock;
        clock = ~clock;

        // entering source card (correct info)
        #10
        credit_number = 10'd500;
        password = 10'd500;
        expiration_date = 11'd2023;

        // balance before entering destination card
        #10
        operation = 3'b001;
        clock = ~clock;
        clock = ~clock;

        // withdrawing before entering destination card
        #10
        withdraw = 10'd100;
        operation = 3'b010;
        clock = ~clock;
        clock = ~clock;

        // balance again
        #10
        operation = 3'b001;
        clock = ~clock;
        clock = ~clock;

        // withdrawing when got no money (no operation)
        #10
        withdraw = 10'd1;
        operation = 3'b010;
        clock = ~clock;
        clock = ~clock;

        // sending money when destination card isn't entered | is incorrect (no operation)
        #10
        destination = 3'b101;
        operation = 3'b011;
        clock = ~clock;
        clock = ~clock;

        // entering destination card (correct info)
        #10
        destination = 10'd1000;
        expiration_date = 11'd2023;

        // transfering more money than got
        #10
        withdraw = 10'd1;
        operation = 3'b011;
        clock = ~clock;
        clock = ~clock;

        // transfering money
        #10
        credit_number = 10'd400;
        expiration_date = 11'd2026;
        password = 10'd400;
        withdraw = 10'd90;
        operation = 3'b011;
        clock = ~clock;
        clock = ~clock;
        
        // entering new card
        #10
        credit_number = 10'd1000;
        expiration_date = 11'd2025;
        password = 10'd1000;
        operation = 3'b001;
        clock = ~clock;
        clock = ~clock;

        // withdrawing
        #10
        withdraw = 10'd15;
        operation = 3'b010;
        clock = ~clock;
        clock = ~clock;

        // receive account report
        #10
        operation = 3'b100;
        clock = ~clock;
        clock = ~clock;
        
        // changing password
        #10
        password = 10'd1000;
        new_password = 10'd1;
        operation = 3'b101;
        clock = ~clock;
        clock = ~clock;

        // entering old password (wrong password, no operation)
        #10
        withdraw = 10'd5;
        password = 10'd1000;
        operation = 3'b010;
        clock = ~clock;
        clock = ~clock;
        
        // entering new password (changed password, correct operation)
        #10
        password = 10'd1;
        operation = 3'b010;
        clock = ~clock;
        clock = ~clock;

        // exiting
        #10
        exit = 1;

        // no operation in exit mode
        #10
        password = 10'd1;
        operation = 3'b001;
        clock = ~clock;
        clock = ~clock;
        
        // back to functioning
        #10
        exit = 0;
        password = 10'd1;
        operation = 3'b001;
        clock = ~clock;
        clock = ~clock;

        // banning account for entering 3 wrong password & not operating until it pays unban cost
        #10
        credit_number = 10'd900;
        expiration_date = 11'd2027;
        password = 10'd901;
        operation = 3'b001;
        clock = ~clock;
        clock = ~clock;
        #10
        password = 10'd902;
        clock = ~clock;
        clock = ~clock;
        #10
        password = 10'd903;
        clock = ~clock;
        clock = ~clock;
        #10
        password = 10'd900;
        operation = 3'b010;
        clock = ~clock;
        clock = ~clock;
        #10
        password = 10'd900;
        operation = 3'b011;
        clock = ~clock;
        clock = ~clock;
        #10
        password = 10'd900;
        operation = 3'b110;
        clock = ~clock;
        clock = ~clock;
        #10
        password = 10'd900;
        operation = 3'b001;
        clock = ~clock;
        clock = ~clock;

        // staying banned when the account doesn't have enough money
        #10
        password = 10'd901;
        clock = ~clock;
        clock = ~clock;
        #10
        password = 10'd902;
        clock = ~clock;
        clock = ~clock;
        #10
        password = 10'd903;
        clock = ~clock;
        clock = ~clock;
        #10
        password = 10'd900;
        operation = 3'b110;
        clock = ~clock;
        clock = ~clock;
    end
endmodule