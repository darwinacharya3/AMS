import 'package:flutter/material.dart';

class RemarksCaptchaSection extends StatefulWidget {
  final Map<String, dynamic> formData;

  const RemarksCaptchaSection({
    Key? key, 
    required this.formData,
  }) : super(key: key);

  @override
  State<RemarksCaptchaSection> createState() => _RemarksCaptchaSectionState();
}

class _RemarksCaptchaSectionState extends State<RemarksCaptchaSection> {
  final TextEditingController _captchaController = TextEditingController();
  // String _captchaImage = 'assets/captcha.png'; // Replace with actual captcha image
  
  @override
  void dispose() {
    _captchaController.dispose();
    super.dispose();
  }
  
  void _refreshCaptcha() {
    // In a real app, you'd call an API to get a new captcha
    setState(() {
      // Simulate captcha refresh
      // _captchaImage = 'assets/captcha.png';
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Information',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF205EB5),
          ),
        ),
        const SizedBox(height: 12),
        
        // Remarks TextArea
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Remarks',
            prefixIcon: const Icon(Icons.comment),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
          maxLines: 4,
          onSaved: (value) => widget.formData['remarks'] = value,
        ),
        const SizedBox(height: 16),
        
        // Captcha - Responsive
        const Text(
          'Enter Captcha',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF205EB5),
          ),
        ),
        const SizedBox(height: 8),
        
        // Captcha with responsive layout
        if (isSmallScreen)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Captcha image with refresh button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'CAPTCHA', // Replace with actual captcha image
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _refreshCaptcha,
                    icon: const Icon(Icons.refresh),
                    color: const Color(0xFF205EB5),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Captcha input field
              TextFormField(
                controller: _captchaController,
                decoration: InputDecoration(
                  hintText: 'Enter Captcha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the captcha';
                  }
                  return null;
                },
                onSaved: (value) => widget.formData['captcha'] = value,
              ),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Captcha input field
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _captchaController,
                  decoration: InputDecoration(
                    hintText: 'Enter Captcha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the captcha';
                    }
                    return null;
                  },
                  onSaved: (value) => widget.formData['captcha'] = value,
                ),
              ),
              const SizedBox(width: 12),
              // Captcha image
              Expanded(
                flex: 2,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'CAPTCHA', // Replace with actual captcha image
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
              // Refresh button
              IconButton(
                onPressed: _refreshCaptcha,
                icon: const Icon(Icons.refresh),
                color: const Color(0xFF205EB5),
              ),
            ],
          ),
      ],
    );
  }
}