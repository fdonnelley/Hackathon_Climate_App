import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/emissions_utils.dart';
import '../../../routes/app_routes.dart';
import '../../home/controllers/home_controller.dart';
import '../../setup/models/setup_data_model.dart';

/// A bottom sheet for adding carbon usage (energy or transportation)
class AddUsageBottomSheet extends StatefulWidget {
  /// Creates a bottom sheet for adding carbon usage
  const AddUsageBottomSheet({super.key});

  /// Show the bottom sheet
  static Future<void> show({String initialMode = 'transportation'}) {
    return Get.bottomSheet(
      const AddUsageBottomSheet(),
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      settings: RouteSettings(arguments: {'initialMode': initialMode}),
    );
  }

  @override
  State<AddUsageBottomSheet> createState() => _AddUsageBottomSheetState();
}

class AddUsageController extends GetxController {
  final RxDouble estimatedEmissions = 0.0.obs;
  
  void updateEmissions(double value) {
    estimatedEmissions.value = value;
  }
  
  @override
  void onInit() {
    super.onInit();
    // Ensure the value is never null
    ever(estimatedEmissions, (val) {
      if (val == null) {
        estimatedEmissions.value = 0.0;
      }
    });
  }
}

class _AddUsageBottomSheetState extends State<AddUsageBottomSheet> {
  final HomeController _homeController = Get.find<HomeController>();
  late final AddUsageController _usageController;
  late final String _controllerTag;
  
  // Mode selection
  late final RxString _selectedMode;
  
  // Energy inputs
  final TextEditingController _electricBillController = TextEditingController();
  final TextEditingController _gasBillController = TextEditingController();
  
  // Transportation inputs
  final Rx<TransportMode> _selectedTransportMode = TransportMode.car.obs;
  final Rx<CarType?> _selectedCarType = Rx<CarType?>(null);
  final Rx<CarUsageType?> _selectedCarUsageType = Rx<CarUsageType?>(null);
  final Rx<PublicTransportType?> _selectedPublicTransportType = Rx<PublicTransportType?>(null);
  final Rx<int> _selectedCarpoolSize = 1.obs;
  final TextEditingController _milesController = TextEditingController();
  final TextEditingController _mpgController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    // Get initial mode from route arguments if provided
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('initialMode')) {
      _selectedMode = RxString(args['initialMode'] as String);
    } else {
      _selectedMode = RxString('transportation'); // Default to transportation
    }
    
    // Create a unique tag for this instance
    _controllerTag = 'add_usage_${hashCode}';
    _usageController = Get.put(AddUsageController(), tag: _controllerTag);
    
    // Add listeners to update estimated emissions in real-time
    _electricBillController.addListener(_updateEstimatedEmissions);
    _gasBillController.addListener(_updateEstimatedEmissions);
    _milesController.addListener(_updateEstimatedEmissions);
    _mpgController.addListener(_updateEstimatedEmissions);
  }

  @override
  void dispose() {
    _electricBillController.removeListener(_updateEstimatedEmissions);
    _gasBillController.removeListener(_updateEstimatedEmissions);
    _milesController.removeListener(_updateEstimatedEmissions);
    _mpgController.removeListener(_updateEstimatedEmissions);
    
    _electricBillController.dispose();
    _gasBillController.dispose();
    _milesController.dispose();
    _mpgController.dispose();
    
    // Clean up the controller using the stable tag
    Get.delete<AddUsageController>(tag: _controllerTag);
    super.dispose();
  }

  void _updateEstimatedEmissions() {
    if (_selectedMode.value == 'transportation') {
      final milesText = _milesController.text.trim();
      if (milesText.isEmpty) {
        _usageController.updateEmissions(0.0);
        return;
      }
      
      final miles = double.tryParse(milesText) ?? 0;
      if (miles <= 0) {
        _usageController.updateEmissions(0.0);
        return;
      }
      
      // Create a transportation method object for tracking
      final transportMethod = TransportationMethod(
        mode: _selectedTransportMode.value,
        milesPerWeek: miles, // We'll use this same field but interpret it as miles per trip
        mpg: _mpgController.text.isEmpty ? null : double.parse(_mpgController.text),
        carType: _selectedCarType.value,
        carUsageType: _selectedCarUsageType.value,
        carpoolSize: _selectedCarUsageType.value == CarUsageType.carpool ? _selectedCarpoolSize.value : null,
      );
      
      // Calculate emissions in lbs
      final emissionsLbs = _calculateTransportEmissions(transportMethod);
      _usageController.updateEmissions(emissionsLbs);
    } else if (_selectedMode.value == 'energy') {
      final electricText = _electricBillController.text.trim();
      final gasText = _gasBillController.text.trim();
      
      final electricBill = electricText.isEmpty ? 0 : double.tryParse(electricText) ?? 0;
      final gasBill = gasText.isEmpty ? 0 : double.tryParse(gasText) ?? 0;
      
      // Calculate emissions in lbs
      final emissionsLbs = _calculateEnergyEmissions(electricBill.toDouble(), gasBill.toDouble());
      _usageController.updateEmissions(emissionsLbs);
    }
    // No need to call update() - we're using reactive properties now
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Content area with scrolling capability
          Container(
            constraints: BoxConstraints(
              maxHeight: size.height * 0.7, // Limit maximum height
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle bar at the top
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Title and close button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add Carbon Usage',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Get.back(),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Mode selector tabs
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            children: [
                              _buildTabOption(context, 'Transportation', 'transportation', Icons.directions_car),
                              _buildTabOption(context, 'Energy', 'energy', Icons.bolt),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Form content based on selected mode - use a listener to properly update
                        Obx(() => _selectedMode.value == 'transportation'
                          ? _buildTransportationForm(context)
                          : _buildEnergyForm(context)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Button at the bottom
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addUsage,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.only(top: 12, bottom: 36),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                alignment: Alignment.center,
              ),
              child: const Text(
                'Add to Carbon Tracker',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabOption(
    BuildContext context, 
    String label, 
    String mode, 
    IconData icon
  ) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: Obx(() {
        final isSelected = _selectedMode.value == mode;
        return GestureDetector(
          onTap: () {
            // Set selected mode and force update
            _selectedMode.value = mode;
            _updateEstimatedEmissions(); // Update emissions when tab changes
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
  
  Widget _buildEnergyForm(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Monthly Utility Bills',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Electric bill
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Electric Bill',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _electricBillController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Enter amount in dollars',
                  prefixIcon: const Icon(Icons.bolt),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Gas bill
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gas Bill',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _gasBillController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Enter amount in dollars',
                  prefixIcon: const Icon(Icons.local_fire_department),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Display estimated emissions using the reactive value
          Obx(() => Text(
            'Estimated emissions: ${EmissionsUtils.formatPounds(_usageController.estimatedEmissions.value)} lbs CO₂e per week',
            style: theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 14),
          )),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTransportationForm(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Transportation Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Transportation type
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transportation Type',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<TransportMode>(
                    isExpanded: true,
                    value: _selectedTransportMode.value,
                    hint: const Text("Select transportation type"),
                    items: TransportMode.values.map((mode) {
                      return DropdownMenuItem<TransportMode>(
                        value: mode,
                        child: Row(
                          children: [
                            Icon(_getTransportIcon(mode), size: 20),
                            const SizedBox(width: 12),
                            Text(mode.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        _selectedTransportMode.value = newValue;
                        // Reset car-specific selections when changing transport mode
                        if (newValue != TransportMode.car) {
                          _selectedCarType.value = null;
                          _selectedCarUsageType.value = null;
                        } else {
                          // Set defaults for car
                          _selectedCarType.value = CarType.sedan;
                          _selectedCarUsageType.value = CarUsageType.personal;
                        }
                        _updateEstimatedEmissions();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Car-specific options (only for Car)
          Obx(() => _selectedTransportMode.value == TransportMode.car
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car Type selection
                  Text(
                    'Car Type',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Car type selection with radio-button style
                  Wrap(
                    spacing: 10,
                    children: [
                      _buildCarTypeOption(context, CarType.sedan),
                      _buildCarTypeOption(context, CarType.suv),
                      _buildCarTypeOption(context, CarType.truck),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: [
                      _buildCarTypeOption(context, CarType.hybrid),
                      _buildCarTypeOption(context, CarType.electric),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // How do you use this car?
                  Text(
                    'How do you use this car?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Car usage type selection with radio-button style
                  Wrap(
                    spacing: 10,
                    children: [
                      _buildCarUsageTypeOption(context, CarUsageType.personal),
                      _buildCarUsageTypeOption(context, CarUsageType.taxi),
                      _buildCarUsageTypeOption(context, CarUsageType.carpool),
                    ],
                  ),
                  
                  // Carpool size selection (only for carpool)
                  Obx(() => _selectedCarUsageType.value == CarUsageType.carpool
                    ? Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          children: [
                            Text(
                              'Carpool Size: ',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 16),
                                    onPressed: () {
                                      if (_selectedCarpoolSize.value > 2) {
                                        _selectedCarpoolSize.value--;
                                        _updateEstimatedEmissions();
                                      }
                                    },
                                  ),
                                  Text(
                                    '${_selectedCarpoolSize.value}',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 16),
                                    onPressed: () {
                                      if (_selectedCarpoolSize.value < 10) {
                                        _selectedCarpoolSize.value++;
                                        _updateEstimatedEmissions();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox()
                  ),
                  
                  const SizedBox(height: 16),
                ],
              )
            : const SizedBox()
          ),
          
          // Miles for this trip
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Miles for this Trip',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _milesController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Enter miles for this trip',
                  prefixIcon: const Icon(Icons.map),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // MPG (only for Car)
          Obx(() => _selectedTransportMode.value == TransportMode.car && 
                  _selectedCarType.value != CarType.electric
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Miles per Gallon (MPG)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _mpgController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*$'))],
                    decoration: InputDecoration(
                      hintText: 'Enter your vehicle\'s MPG',
                      prefixIcon: const Icon(Icons.local_gas_station),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    onChanged: (_) => _updateEstimatedEmissions(),
                  ),
                  const SizedBox(height: 16),
                ],
              )
            : const SizedBox()
          ),
          
          // Display estimated emissions using the reactive value
          Obx(() => Text(
            'Estimated emissions: ${EmissionsUtils.formatPounds(_usageController.estimatedEmissions.value)} lbs CO₂e for this trip',
            style: theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 14),
          )),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  // Helper method to build car type option buttons
  Widget _buildCarTypeOption(BuildContext context, CarType carType) {
    final theme = Theme.of(context);
    final isSelected = _selectedCarType.value == carType;
    
    return GestureDetector(
      onTap: () {
        _selectedCarType.value = carType;
        _updateEstimatedEmissions();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade100 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.green.shade700 : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.green.shade700,
                size: 20,
              ),
            if (isSelected) const SizedBox(width: 8),
            Text(
              carType.displayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.green.shade700 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to build car usage type option buttons
  Widget _buildCarUsageTypeOption(BuildContext context, CarUsageType usageType) {
    final theme = Theme.of(context);
    final isSelected = _selectedCarUsageType.value == usageType;
    
    return GestureDetector(
      onTap: () {
        _selectedCarUsageType.value = usageType;
        // Initialize carpool size to 2 when selecting carpool
        if (usageType == CarUsageType.carpool && _selectedCarpoolSize.value < 2) {
          _selectedCarpoolSize.value = 2;
        }
        _updateEstimatedEmissions();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade100 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.green.shade700 : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.green.shade700,
                size: 20,
              ),
            if (isSelected) const SizedBox(width: 8),
            Text(
              usageType.displayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.green.shade700 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _addUsage() {
    if (_selectedMode.value == 'transportation') {
      // For transportation usage
      final milesText = _milesController.text.trim();
      if (milesText.isEmpty) {
        _showError('Please enter miles for this trip');
        return;
      }
      
      final miles = double.tryParse(milesText) ?? 0;
      if (miles <= 0) {
        _showError('Please enter a valid miles value');
        return;
      }
      
      // Calculate CO2 emissions based on transportation type
      double co2Emissions = 0;
      
      // Create a transportation method object for tracking
      final transportMethod = TransportationMethod(
        mode: _selectedTransportMode.value,
        milesPerWeek: miles, // We'll use this same field but interpret it as miles per trip
        mpg: _mpgController.text.isEmpty ? null : double.parse(_mpgController.text),
        carType: _selectedCarType.value,
        carUsageType: _selectedCarUsageType.value,
        carpoolSize: _selectedCarUsageType.value == CarUsageType.carpool ? _selectedCarpoolSize.value : null,
      );
      
      // Calculate emissions in pounds
      co2Emissions = _calculateTransportEmissions(transportMethod);
      
      // Add to tracker (directly in pounds)
      _homeController.addCarbonUsage(co2Emissions, 'transportation');
      
      // Show success message
      Get.back();
      _showSuccess('Added ${miles.toStringAsFixed(1)} miles of ${_selectedTransportMode.value.displayName} trip');
    } 
    else if (_selectedMode.value == 'energy') {
      // For energy usage
      final electricText = _electricBillController.text.trim();
      final gasText = _gasBillController.text.trim();
      
      if (electricText.isEmpty && gasText.isEmpty) {
        _showError('Please enter at least one utility bill amount');
        return;
      }
      
      final electricBill = double.tryParse(electricText) ?? 0;
      final gasBill = double.tryParse(gasText) ?? 0;
      
      // Calculate CO2 emissions in pounds
      double co2Emissions = _calculateEnergyEmissions(electricBill, gasBill);
      
      // Add to tracker (directly in pounds)
      _homeController.addCarbonUsage(co2Emissions, 'energy');
      
      // Show success message
      Get.back();
      _showSuccess('Added energy usage');
    }
  }
  
  double _calculateTransportEmissions(TransportationMethod transport) {
    // Values in lbs CO2e per mile (simplified for demo)
    switch (transport.mode) {
      case TransportMode.car:
        // Average car produces ~0.89 lbs CO2e per mile
        // More accurate calculation with MPG: (19.6 lbs CO2e per gallon) / MPG
        double emissionsPerMile = transport.mpg != null && transport.mpg! > 0
            ? 19.6 / transport.mpg!
            : 0.89;
            
        // Apply carpooling factor if applicable
        if (transport.carUsageType == CarUsageType.carpool && 
            transport.carpoolSize != null &&
            transport.carpoolSize! > 1) {
          emissionsPerMile /= transport.carpoolSize!;
        }
        
        // Calculate for a single trip (milesPerWeek field is now used for trip miles)
        double emissions = emissionsPerMile * transport.milesPerWeek;
        // Return directly in pounds
        return emissions;
        
      case TransportMode.publicTransportation:
        // Average public transit ~0.35 lbs CO2e per mile (varies by type)
        return 0.35 * transport.milesPerWeek;
        
      case TransportMode.bicycle:
      case TransportMode.walking:
        // Zero emissions for walking and biking
        return 0;
        
      case TransportMode.airplane:
        // Average airplane ~0.53 lbs CO2e per mile (simplified)
        return 0.53 * transport.milesPerWeek;
    }
  }
  
  double _calculateEnergyEmissions(double electricBill, double gasBill) {
    // Very simplified calculation for demo purposes
    // More accurate calculation would use kWh and therms
    // Average emissions:
    // - Electricity: ~0.92 pounds CO2e per dollar
    // - Natural gas: ~0.84 pounds CO2e per dollar
    
    // Calculate directly in pounds
    double electricEmissions = electricBill * 0.92;
    double gasEmissions = gasBill * 0.84;
    
    // Return weekly amount in pounds
    return electricEmissions + gasEmissions;
  }
  
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
  
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
  
  // Helper methods for transportation display
  String _getTransportTitle(TransportationMethod transport) {
    switch (transport.mode) {
      case TransportMode.car:
        return transport.carUsageType == CarUsageType.carpool
            ? 'Carpool (${transport.carpoolSize} people)'
            : transport.carUsageType?.displayName ?? 'Car';
      case TransportMode.publicTransportation:
        return transport.publicTransportType?.displayName ?? 'Public Transit';
      default:
        return transport.mode.displayName;
    }
  }
  
  IconData _getTransportIcon(TransportMode mode) {
    switch (mode) {
      case TransportMode.walking:
        return Icons.directions_walk;
      case TransportMode.bicycle:
        return Icons.directions_bike;
      case TransportMode.car:
        return Icons.directions_car;
      case TransportMode.publicTransportation:
        return Icons.directions_bus;
      case TransportMode.airplane:
        return Icons.flight;
      default:
        return Icons.question_mark;
    }
  }
  
  String _getTransportIconName(TransportMode mode) {
    switch (mode) {
      case TransportMode.walking:
        return 'directions_walk';
      case TransportMode.bicycle:
        return 'directions_bike';
      case TransportMode.car:
        return 'directions_car';
      case TransportMode.publicTransportation:
        return 'directions_bus';
      case TransportMode.airplane:
        return 'flight';
    }
  }
}
