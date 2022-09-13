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

module exists(credit_number, expiration_date, index, function_result);
    input [9:0] credit_number;
    input [10:0] expiration_date;
    output [3:0] index;
    output reg function_result;

    reg [9:0] credit_number_bank [0:15];

    initial begin
        credit_number_bank[0] = 10'd100;
        credit_number_bank[1] = 10'd200;
        credit_number_bank[2] = 10'd300;
        credit_number_bank[3] = 10'd400;
        credit_number_bank[4] = 10'd500;
        credit_number_bank[5] = 10'd600;
        credit_number_bank[6] = 10'd700;
        credit_number_bank[7] = 10'd800;
        credit_number_bank[8] = 10'd900;
        credit_number_bank[9] = 10'd1000;
        credit_number_bank[10] = 10'd1003;
        credit_number_bank[11] = 10'd1006;
        credit_number_bank[12] = 10'd1009;
        credit_number_bank[13] = 10'd1012;
        credit_number_bank[14] = 10'd1015;
        credit_number_bank[15] = 10'd1018;
    end

    integer i;

    // looking for index when credit_number changes
    reg [3:0] index_temp;
    always @(credit_number) begin
        function_result = 1'b0;
        for (i = 0; i < 16; i = i + 1) begin
            if (credit_number == credit_number_bank[i]) begin
                index_temp = i;
                function_result = 1'b1;
            end
        end
    end

    assign index = index_temp;
endmodule

module ATM(clock, credit_number, destination, withdraw, expiration_date, password, new_password, operation, exit, card_declined);
    input clock;
    input [9:0] credit_number, destination, withdraw, password, new_password;
    input [10:0] expiration_date;
    input [2:0] operation;
    input exit;
    output reg card_declined;
    
    reg [2:0] current_state = 3'b111;

    reg [9:0] balance_bank [0:15];
    reg [9:0] deposit_amount [0:15];
    reg [9:0] passcode [0:15];
    reg [1:0] wrong_tries [0:15];

    integer i;
    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            balance_bank[i] = `minimum_balance;
            deposit_amount[i] = 10'd0;
            wrong_tries[i] = 2'b00;
        end

        passcode[0] = 10'd100;
        passcode[1] = 10'd200;
        passcode[2] = 10'd300;
        passcode[3] = 10'd400;
        passcode[4] = 10'd500;
        passcode[5] = 10'd600;
        passcode[6] = 10'd700;
        passcode[7] = 10'd800;
        passcode[8] = 10'd900;
        passcode[9] = 10'd1000;
        passcode[10] = 10'd1003;
        passcode[11] = 10'd1006;
        passcode[12] = 10'd1009;
        passcode[13] = 10'd1012;
        passcode[14] = 10'd1015;
        passcode[15] = 10'd1018;
    end

    // find indexes if exist
    wire [3:0] source_index;
    wire source_exists;
    exists does_source_account_exist(credit_number, expiration_date, source_index, source_exists);
    wire [3:0] destination_index;
    wire destination_exists;
    exists does_destination_account_exist(destination, expiration_date, destination_index, destination_exists);

    // running the block by clock change or exit change
    always @(negedge clock or exit) begin
        card_declined = 1'b0;

        // exiting main menu
        if ((exit == 1'b1) | (source_exists == 0) | (destination_exists == 0) | (password != passcode[source_index]) | (expiration_date <= `current_date) | ((wrong_tries[source_index] == 2'b11) & (operation != 3'b110))) begin
            current_state = 3'b111;
        end

        // reentering the main menu if the cards info are correct
        if (current_state == 3'b111) begin
            if (exit == 1'b1) begin
                $display("Exited!\n");
            end
            else if (password != passcode[source_index]) begin
                $display("Wrong password!\n");
                if (wrong_tries[source_index] != 2'b11) begin
                    wrong_tries[source_index] = wrong_tries[source_index] + 2'b01;
                end
            end
            else if (expiration_date <= `current_date) begin
                $display("Expired card!\n");
            end
            else if ((wrong_tries[source_index] == 2'b11) & (operation != 3'b110)) begin
                $display("3 Wrong password, Your account is banned!\n");
            end
            else begin
                $display("Authenticating...");
                if (source_exists == 1) begin
                    current_state = 3'b000;
                end
                else begin
                    $display("Authentication failed\n");
                end
            end
        end

        // setting the operation to function
        if (current_state == 3'b000) begin
            $display("Waiting for operation...");
            current_state = operation;
        end
    
        // entering balance state & when done entering main menu
        if (current_state == 3'b001) begin
            $display("balance: %d\n", balance_bank[source_index]);
            current_state = 3'b000;
        end

        // withdrawing money then main menu
        if (current_state == 3'b010) begin
            if ((withdraw <= balance_bank[source_index])) begin
                balance_bank[source_index] = balance_bank[source_index] - withdraw;
                $display("withdrawn!");
                $display("new balance: %d\n", balance_bank[source_index]);
            end
            else begin
                $display("Insuffucient balance!\n");
                card_declined = 1'b1;
            end
            current_state = 3'b000;
        end

        // transfering money then main menu or back to waiting for card when there's no destination card entered
        if ((current_state == 3'b011) & (destination_exists == 1)) begin
            if ((withdraw <= balance_bank[source_index]) & (withdraw + balance_bank[destination_index] < 1024)) begin
                balance_bank[source_index] = balance_bank[source_index] - withdraw;
                balance_bank[destination_index] = balance_bank[destination_index] + withdraw;
                deposit_amount[destination_index] = deposit_amount[destination_index] + withdraw; // Needed in state 3'b100
                $display("send!");
                $display("new balance: %d\n", balance_bank[source_index]);
            end
            else begin
                $display("Insufficient balance or reached the limit!\n");
                card_declined = 1'b1;
            end
            current_state = 3'b000;
        end
        else begin
            if (current_state == 3'b011) begin
                $display("Failed! enter the destination card.\n");
                current_state = 3'b111;
            end
        end

        // showing account report then main menu (only using deposit amount and finding withdraw amount with default balance)
        if (current_state == 3'b100) begin
            $display("Account report ==> deposited: +%d | withdrawed: -%d\n", deposit_amount[source_index], `minimum_balance + deposit_amount[source_index] - balance_bank[source_index]);
            current_state = 3'b000;
        end

        // changing password then back to main menu
        if (current_state == 3'b101) begin
            passcode[source_index] = new_password;
            $display("Changed your password!\n");
            current_state = 3'b000;
        end

        // unbanning if has the cost then back to main menu
        if (current_state == 3'b110) begin
            if (balance_bank[source_index] >= `unban_cost) begin
                $display("Withdrawing unban service cost ($100)...");
                balance_bank[source_index] = balance_bank[source_index] - `unban_cost;
                $display("Unbanning your account...!\n");
                wrong_tries[source_index] = 2'b00;
            end
            else begin
                $display("You don't have the minimum money needed for unban service!");
            end
            current_state = 3'b000;
        end
    end
endmodule