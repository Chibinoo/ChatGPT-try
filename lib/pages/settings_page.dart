import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/entry_provider.dart';
import 'package:flutter_application_1/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryProvider>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<EntryProvider>(
          builder: (context, provider, _){
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                //Storage Mode
                const Text(
                  'Storage Mode',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Local Storage'),
                    Switch(
                      value: provider.useCloud,
                      onChanged: (value)async{
                        if(!value&&provider.useCloud){
                          //switch from cloud to local
                          bool? deleteCloud=await showDialog<bool>(
                            context: context,
                            builder: (ctx)=>AlertDialog(
                              title: const Text('Delete Cloud Data?'),
                              content: const Text(
                                'Do you want to delete your cloud data after syncing it ti local storage?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: ()=>Navigator.of(ctx).pop(true), 
                                  child: const Text('Delete Cloud Data')
                                )
                              ],
                            )
                          );
                          if(deleteCloud==null)return;//dissmissed
                          await provider.mergeCloudToLocal(deleteCloud);
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(deleteCloud
                                ?'Cloud data merged and deleted'
                                :'Cloud data merged but kept online'
                              ),
                            ),
                          );
                        } else if(value&& !provider.useCloud){
                          //switching local to cloud
                          await provider.toggelStorage(true);
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:Text('Local data merged to Cloud')),
                          );
                        }
                      }
                    ),
                    const Text('Cloud Storage'),
                  ],
                ),

                //Theme
                const Text(
                  'Theme',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoSwitch(
                      value: Provider.of<ThemeProvider>(context).isDarkMode, 
                      onChanged: (value)=>Provider.of<ThemeProvider>(context, listen: false).toggelTheme(),
                    )
                  ],
                ),
                const SizedBox(height: 10),

                //Clear Entries
                const Text(
                  'Clear Entries',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Delete All Entries'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: ()async{
                    final confirm=await showDialog<bool>(
                      context: context, 
                      builder: (ctx)=>AlertDialog(
                        title: const Text('Confirm Deletion'),
                        content: const Text('Are you sure you want to delet ALL entries?'),
                        actions: [
                          TextButton(
                            onPressed: ()=>Navigator.of(ctx).pop(false), 
                            child: const Text('Cancel')
                          ),
                          ElevatedButton(
                            onPressed: ()=>Navigator.of(ctx).pop(true),
                            child: const Text('Delete')
                          )
                        ],
                      ),
                    );
                    if (confirm==true){
                      provider.clearAllEntries();
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All entries have been deleted')),
                      );
                    }
                  }, 
                ),

                //toggel numbered List 
                SwitchListTile(
                  title: const Text('Enabel Numbered List'),
                  value: context.watch<EntryProvider>().listEnabled, 
                  onChanged: (val){
                    context.read<EntryProvider>().toggleListEnabel(val);
                  },
                ),
              //relode streak widget
              ElevatedButton(
            onPressed: () async {
              // If you want to reload streak data, call your provider's method here
              await entryProvider.loadEntries(); // Or your streak reload logic
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Streak reloaded!')),
              );
            },
            child: const Text('Reload Streak Widget'),
          ),
              ]
            );
          }
        ),
      )
    );
  }
}