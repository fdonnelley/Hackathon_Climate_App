import 'package:flutter/material.dart';
import '../controllers/setup_controller.dart';

class WelcomeStep extends StatelessWidget {
  final SetupController controller;
  
  const WelcomeStep({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome header
          Text(
            'Welcome to Carbon Budget Tracker!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          
          const SizedBox(height: 24.0),
          
          // Introduction
          Text(
            'Let\'s set up your personal carbon budget by asking a few questions about your energy usage and transportation habits.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          
          const SizedBox(height: 16.0),
          
          Text(
            'This will help us create a personalized plan for reducing your carbon footprint.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          
          const SizedBox(height: 32.0),
          
          // Name input
          Text(
            'First, what should we call you?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8.0),
          
          TextField(
            controller: controller.nameController,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              hintText: 'Enter your name',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            autofocus: true,
          ),
          
          const SizedBox(height: 32.0),
          
          // Benefits
          Text(
            'Benefits of carbon tracking:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16.0),
          
          // List of benefits
          _buildBenefitItem(
            context,
            icon: Icons.insights,
            title: 'Understand your impact',
            description: 'See how your daily choices affect the environment',
          ),
          
          _buildBenefitItem(
            context,
            icon: Icons.savings,
            title: 'Save money',
            description: 'Reducing carbon often means reducing costs',
          ),
          
          _buildBenefitItem(
            context,
            icon: Icons.public,
            title: 'Help the planet',
            description: 'Be part of the solution to climate change',
          ),
        ],
      ),
    );
  }
  
  Widget _buildBenefitItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 24.0,
            ),
          ),
          
          const SizedBox(width: 16.0),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 4.0),
                
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
