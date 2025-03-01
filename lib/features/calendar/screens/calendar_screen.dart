import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  static const String routeName = '/calendar';
  
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DateTime _today = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  
  // Mock events
  final Map<String, List<CalendarEvent>> _events = {
    '2025-02-27': [
      CalendarEvent(
        title: 'Team Meeting',
        startTime: '10:00 AM',
        endTime: '11:30 AM',
        color: Colors.blue,
      ),
      CalendarEvent(
        title: 'Lunch with Client',
        startTime: '1:00 PM',
        endTime: '2:00 PM',
        color: Colors.orange,
      ),
    ],
    '2025-02-28': [
      CalendarEvent(
        title: 'Project Deadline',
        startTime: '9:00 AM',
        endTime: '5:00 PM',
        color: Colors.red,
      ),
    ],
    '2025-03-01': [
      CalendarEvent(
        title: 'Weekly Review',
        startTime: '4:00 PM',
        endTime: '5:00 PM',
        color: Colors.green,
      ),
    ],
  };

  List<CalendarEvent> get _selectedEvents {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return _events[dateStr] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final month = DateFormat('MMMM yyyy').format(_selectedDate);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddEventDialog(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Month selector
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month - 1,
                          _selectedDate.day,
                        );
                      });
                    },
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    month,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month + 1,
                          _selectedDate.day,
                        );
                      });
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            
            // Days of week header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Expanded(child: Center(child: Text('Sun'))),
                  Expanded(child: Center(child: Text('Mon'))),
                  Expanded(child: Center(child: Text('Tue'))),
                  Expanded(child: Center(child: Text('Wed'))),
                  Expanded(child: Center(child: Text('Thu'))),
                  Expanded(child: Center(child: Text('Fri'))),
                  Expanded(child: Center(child: Text('Sat'))),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Calendar grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
              ),
              itemCount: _getDaysInMonth(_selectedDate.year, _selectedDate.month) + _getFirstDayOfMonth(_selectedDate.year, _selectedDate.month),
              itemBuilder: (context, index) {
                final firstDayOffset = _getFirstDayOfMonth(_selectedDate.year, _selectedDate.month);
                
                // Empty cells before first day of month
                if (index < firstDayOffset) {
                  return const SizedBox();
                }
                
                // Calendar days
                final day = index - firstDayOffset + 1;
                final date = DateTime(_selectedDate.year, _selectedDate.month, day);
                final dateStr = DateFormat('yyyy-MM-dd').format(date);
                final hasEvents = _events.containsKey(dateStr);
                final isSelected = day == _selectedDate.day;
                final isToday = day == _today.day && 
                               _selectedDate.month == _today.month && 
                               _selectedDate.year == _today.year;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : isToday
                              ? theme.colorScheme.primary.withOpacity(0.1)
                              : null,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday && !isSelected
                          ? Border.all(color: theme.colorScheme.primary)
                          : null,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            day.toString(),
                            style: TextStyle(
                              fontWeight: isToday || isSelected ? FontWeight.bold : null,
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (hasEvents)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Selected date events
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    'Events on ${DateFormat('MMM d, yyyy').format(_selectedDate)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedEvents.isNotEmpty)
                    Text(
                      '${_selectedEvents.length} events',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Events list
            Expanded(
              child: _selectedEvents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 48,
                            color: theme.colorScheme.onSurface.withOpacity(0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No events for this day',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {
                              _showAddEventDialog(context);
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Event'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _selectedEvents.length,
                      itemBuilder: (context, index) {
                        final event = _selectedEvents[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 12,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: event.color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            title: Text(
                              event.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${event.startTime} - ${event.endTime}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () {
                                // Show options
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  // Helper to get number of days in month
  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
  
  // Helper to get first day of month (0 = Sunday, 6 = Saturday)
  int _getFirstDayOfMonth(int year, int month) {
    return DateTime(year, month, 1).weekday % 7;
  }
  
  // Show dialog to add a new event
  void _showAddEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Date: ${DateFormat('MMM d, yyyy').format(_selectedDate)}'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Event Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Start Time',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'End Time',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Add new event
              Navigator.of(context).pop();
              
              // Show feedback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Event added successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Add Event'),
          ),
        ],
      ),
    );
  }
}

class CalendarEvent {
  final String title;
  final String startTime;
  final String endTime;
  final Color color;
  
  CalendarEvent({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.color,
  });
}
