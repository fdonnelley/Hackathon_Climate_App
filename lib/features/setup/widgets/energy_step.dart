import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/setup_controller.dart';

class EnergyStep extends StatelessWidget {
  final SetupController controller;
  
  const EnergyStep({
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
          // Energy header
          Text(
            'Home Energy Usage',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          
          const SizedBox(height: 16.0),
          
          // Introduction
          Text(
            'Please enter your average monthly utility bills. This helps us estimate your energy-related carbon emissions.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          
          const SizedBox(height: 32.0),
          
          // Electricity bill section
          _buildEnergyInput(
            context,
            icon: Icons.electric_bolt,
            title: 'Electricity Bill',
            subtitle: 'Average monthly cost',
            controller: controller.electricBillController,
          ),
          
          const SizedBox(height: 24.0),
          
          // Gas bill section
          _buildEnergyInput(
            context,
            icon: Icons.local_fire_department,
            title: 'Natural Gas Bill',
            subtitle: 'Average monthly cost',
            controller: controller.gasBillController,
          ),
          
          const SizedBox(height: 32.0),
          
          // Information card - now collapsible
          CollapsibleInfoCard(
            title: 'Why we need this information',
            content: 'Home energy use is typically responsible for 25-30% of a household\'s carbon footprint. By knowing your energy costs, we can estimate your emissions and suggest effective reduction strategies.\n\nIf you don\'t know the exact amounts, enter your best estimate or leave blank to skip.',
          ),
        ],
      ),
    );
  }
  
  Widget _buildEnergyInput(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required TextEditingController controller,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8.0),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4.0),
          
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 16.0),
          
          // Dollar input field
          TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.attach_money),
              hintText: '0.00',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2.0,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A collapsible information card widget
class CollapsibleInfoCard extends StatefulWidget {
  final String title;
  final String content;
  
  const CollapsibleInfoCard({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);
  
  @override
  _CollapsibleInfoCardState createState() => _CollapsibleInfoCardState();
}

class _CollapsibleInfoCardState extends State<CollapsibleInfoCard> {
  bool _isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and title
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.blue[700],
                    ),
                  ],
                ),
                
                // Content that can be collapsed
                AnimatedCrossFade(
                  firstChild: const SizedBox(height: 0),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      widget.content,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  crossFadeState: _isExpanded 
                      ? CrossFadeState.showSecond 
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
