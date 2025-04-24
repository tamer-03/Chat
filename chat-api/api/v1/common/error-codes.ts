const errorCodes = {
    /* USERNAME ERRORS */
    USERNAME_EMPTY : "Username cannot be empty",
    USERNAME_LENGHT : "Username must be at least 3 and at most 12",
    USERNAME_ALREADY_USING : "This username already exists",

    /* EMAIL ERRORS */
    EMAIL_EMPTY : "Email cannot be empty",
    EMAIL_ALREADY_USING : "This email already exists",
    VALIDATE_EMAIL : "Email cannot validated, send an validated email",
    EMAIL_NOT_VALIDATED : "Email not validated",

    /* PASSWORD ERRORS */
    PASSWORD_WEAK : "The password must contain 6 characters, 1 lower case letter, 1 upper case letter, 1 number and 1 symbol",

    PASSWORDS_NOT_SAME : "Passwords are not the same",
    PASSWORD_UPDATED : "Your password sucessfuly updated",

    /* PHONE ERRORS */
    PHONE_ALREADY_EXISTS : "That phone number already exists",
    PHONE_NOT_VALIDATED : "This phone number not validated",
    PHONE_EMPTY : "Phone number empty",


    /* AUTH MESSAGES */
    ACCOUNT_SUCCESSFULLY_CREATED : "Your account successfully created",
    USER_NOT_FOUND : "User not found",
    WRONG_PASSWORD : "Wrong password",
    SUCCESSFULLY_SIGNED_IN : "Successfully signed in",
    SUCCESSFULLY_SIGN_OUT : "Successfully sign out",

    /* TOKEN MESSAGES */
    TOKEN_MISS : "Token expired",


    /* ANY MESSAGES */
    SOMETHING_WENT_WRONG : "Something went wrong",
    UNKNOWN_DEVICE : "No device or browser information found",
    SUCCESS : "Success",


}

export default errorCodes