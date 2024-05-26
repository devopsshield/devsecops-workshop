function New-ComplexPassword {
    param (
        [int]$length = 12
    )
    
    $upperCase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    $upperCaseArray = $upperCase.ToCharArray()
    $lowerCase = 'abcdefghijklmnopqrstuvwxyz'
    $lowerCaseArray = $lowerCase.ToCharArray()
    $numbers = '0123456789'
    $numbersArray = $numbers.ToCharArray()
    $specialChars = '!@#$%^&*()_-+=<>?'
    $specialCharsArray = $specialChars.ToCharArray()

    $randomUpperCase = $upperCaseArray | Get-Random -Count 1
    $randomLowerCase = $lowerCaseArray | Get-Random -Count 1
    $randomNumber = $numbersArray | Get-Random -Count 1
    $randomSpecialChar = $specialCharsArray | Get-Random -Count 1
    
    # Ensure the password includes at least one character from each set
    $initialPassword = $randomUpperCase + 
    $randomLowerCase + 
    $randomNumber + 
    $randomSpecialChar
    
    $allChars = $upperCase + $lowerCase + $numbers + $specialChars
    $allCharsArray = $allChars.ToCharArray()
    
    # Fill the rest of the password up to the desired length
    for ($i = $initialPassword.Length; $i -lt $length; $i++) {
        $initialPassword += $allCharsArray | Get-Random -Count 1
    }

    # Shuffle the password to prevent predictable patterns
    $shuffledPasswordChars = $initialPassword.ToCharArray() | Get-Random -Count $length
    $shuffledPassword = -join $shuffledPasswordChars
    
    return $shuffledPassword
}

# Generate a random password
$randomPassword = New-ComplexPassword -length 12
Write-Host "Random password: $randomPassword"