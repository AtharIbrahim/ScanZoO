import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../sticker/repositories/sticker_repository.dart';
import '../../sticker/models/emergency_contact.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final StickerRepository _repository = StickerRepository();
  List<EmergencyContact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await _repository.getEmergencyContacts();
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading contacts: ${e.toString()}'),
            backgroundColor: AppColors.emergencyRed,
          ),
        );
      }
    }
  }

  Future<void> _saveContacts() async {
    try {
      await _repository.addEmergencyContacts(_contacts);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contacts saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving contacts: ${e.toString()}'),
            backgroundColor: AppColors.emergencyRed,
          ),
        );
      }
    }
  }

  void _addContact() {
    showDialog(
      context: context,
      builder: (context) => _ContactDialog(
        onSave: (contact) {
          setState(() {
            _contacts.add(contact);
          });
          _saveContacts();
        },
      ),
    );
  }

  void _editContact(int index) {
    showDialog(
      context: context,
      builder: (context) => _ContactDialog(
        contact: _contacts[index],
        onSave: (contact) {
          setState(() {
            _contacts[index] = contact;
          });
          _saveContacts();
        },
      ),
    );
  }

  void _deleteContact(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${_contacts[index].name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _contacts.removeAt(index);
              });
              _saveContacts();
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.emergencyRed),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Emergency Contacts',
          style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.sticker_color))
          : _contacts.isEmpty
              ? _buildEmptyState()
              : _buildContactsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContact,
        backgroundColor: AppColors.sticker_color,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contacts_outlined,
              size: 80,
              color: AppColors.sticker_color,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Emergency Contacts',
              style: AppTypography.h3.copyWith(color: AppColors.sticker_color),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add contacts who should be notified when someone scans your sticker',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList() {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          color: theme.cardColor,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: contact.isPrimary
                  ? AppColors.emergencyRed
                  : AppColors.sticker_color,
              child: Icon(
                contact.isPrimary ? Icons.star : Icons.person,
                color: Colors.white,
              ),
            ),
            title: Text(
              contact.name,
              style: AppTypography.bodyLarge.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xs),
                Text(
                  contact.phone,
                  style: AppTypography.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(1),
                  ),
                ),
                Text(
                  contact.relationship,
                  style: AppTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(1),
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface.withOpacity(0.5)),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: AppColors.sticker_color),
                      const SizedBox(width: AppSpacing.sm),
                      const Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppColors.emergencyRed),
                      const SizedBox(width: AppSpacing.sm),
                      const Text('Delete'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  _editContact(index);
                } else if (value == 'delete') {
                  _deleteContact(index);
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class _ContactDialog extends StatefulWidget {
  final EmergencyContact? contact;
  final Function(EmergencyContact) onSave;

  const _ContactDialog({
    this.contact,
    required this.onSave,
  });

  @override
  State<_ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<_ContactDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _relationshipController;
  bool _isPrimary = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _phoneController = TextEditingController(text: widget.contact?.phone ?? '');
    _relationshipController = TextEditingController(text: widget.contact?.relationship ?? '');
    _isPrimary = widget.contact?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: theme.cardColor,
      title: Text(
        widget.contact == null ? 'Add Contact' : 'Edit Contact',
        style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person, color: AppColors.sticker_color),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(Icons.phone, color: AppColors.sticker_color),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _relationshipController,
              decoration: InputDecoration(
                labelText: 'Relationship',
                prefixIcon: Icon(Icons.people, color: AppColors.sticker_color),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            CheckboxListTile(
              title: Text(
                'Primary Contact',
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              value: _isPrimary,
              onChanged: (value) {
                setState(() {
                  _isPrimary = value ?? false;
                });
              },
              activeColor: AppColors.emergencyRed,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.sticker_color)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isEmpty ||
                _phoneController.text.isEmpty ||
                _relationshipController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill all fields'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final contact = EmergencyContact(
              id: widget.contact?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
              name: _nameController.text,
              phone: _phoneController.text,
              relationship: _relationshipController.text,
              isPrimary: _isPrimary,
            );

            widget.onSave(contact);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.sticker_color,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
