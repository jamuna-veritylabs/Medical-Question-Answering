import jwt

# Replace 'YOUR_JWT_TOKEN_HERE' with your actual token.
token = ''

# Decode without verifying the signature (only for decoding/inspection; do not use in production)
decoded = jwt.decode(token, options={"verify_signature": False})
print(decoded)

# Accessing specific claims:
groups = decoded.get('cognito:groups')
print("Cognito Groups:", groups)

organization_id = decoded.get('custom:organizationId')
print("Organization ID:", organization_id)
