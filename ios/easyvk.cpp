//
//  easyvk.cpp
//  Runner
//
//  Created by Abhijeet Nikam on 19/03/23.
//


#include "easyvk.hpp"
#include <vulkan/vulkan.h>
#include <vector>
#include <array>
#include <iostream>

#include <fstream>
#include <filesystem>
#include "assert.h"
#include <fstream>
//#include <android/log.h>
#include <set>
#include <chrono>
#include <thread>

using namespace std;


bool printDeviceInfo = false;
bool _enableValidationLayers = false;

// Printing log tool for Android Studio's Logcat
//#define LOGD(...) ((void)__android_log_print(ANDROID_LOG_DEBUG, "EASYVK", __VA_ARGS__))

// Macro for checking Vulkan callbacks
#define vulkanCheck(result) { vulkanAssert((result), __FILE__, __LINE__); }

inline void vulkanAssert(VkResult result, const char *file, int line, bool abort = true){
    if (result != VK_SUCCESS) {
        std::ofstream outputFile("/data/data/com.example.litmustestandroid/files/litmustest_message_passing_coherency_dis.txt");
        outputFile << "vulkanAssert: ERROR " << result << "\n" << file << "\nline: " << line;
        outputFile.close();
        std::ofstream externalOutputFile("/storage/emulated/0/Android/data/com.example.litmustestandroid/files/litmustest_message_passing_coherency_dis.txt");
        externalOutputFile << "vulkanAssert: ERROR " << result << "\n" << file << "\nline: " << line;
        externalOutputFile.close();
      //  LOGD("vulkanAssert: ERROR %d \n File: %s \n Line: %d", result, file, line);
        
    cout << "vulkanAssert: ERROR "<< result << "File" << file << line;
        exit(1);
    }
}

namespace easyvk {

    static auto VKAPI_ATTR debugReporter(
            VkDebugReportFlagsEXT , VkDebugReportObjectTypeEXT, uint64_t, size_t, int32_t
            , const char*                pLayerPrefix
            , const char*                pMessage
            , void*                      pUserData)-> VkBool32 {
        std::ofstream debugFile("/data/data/com.example.litmustestandroid/files/debug.txt");
        debugFile << "[Vulkan]:" << pLayerPrefix << ": " << pMessage << "\n";
        debugFile.close();
      //  LOGD("[Vulkan]: %s: %s\n", pLayerPrefix, pMessage);
        cout << "[Vulkan]: " <<pLayerPrefix << ", " <<  pMessage;
        return VK_FALSE;
        }

    Instance::Instance(bool _enableValidationLayers) {
        enableValidationLayers = _enableValidationLayers;
        std::vector<const char *> enabledLayers;
        std::vector<const char *> enabledExtensions;

        if (enableValidationLayers) {
            enabledLayers.push_back("VK_LAYER_KHRONOS_validation");
            enabledExtensions.push_back(VK_EXT_DEBUG_REPORT_EXTENSION_NAME);
           // enabledExtensions.push_back("VK_KHR_shader_non_semantic_info");
        }

        // Define app information
        VkApplicationInfo appInfo {
            VK_STRUCTURE_TYPE_APPLICATION_INFO,
            nullptr,
            "Litmus Tester",
            0,
            "LSD Lab",
            0,
            VK_API_VERSION_1_1
        };

        // Define instance create info
        VkInstanceCreateInfo createInfo {
            VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
            nullptr,
            VkInstanceCreateFlags {},
            &appInfo,
            (uint32_t)(enabledLayers.size()),
            enabledLayers.data(),
            (uint32_t)(enabledExtensions.size()),
            enabledExtensions.data()
        };

        // Create instance
        vulkanCheck(vkCreateInstance(&createInfo, nullptr, &instance));

        if (enableValidationLayers) {
            VkDebugReportCallbackCreateInfoEXT debugCreateInfo {
                VK_STRUCTURE_TYPE_DEBUG_REPORT_CALLBACK_CREATE_INFO_EXT,
                nullptr,
                VK_DEBUG_REPORT_ERROR_BIT_EXT | VK_DEBUG_REPORT_WARNING_BIT_EXT
                | VK_DEBUG_REPORT_PERFORMANCE_WARNING_BIT_EXT,
                debugReporter
            };
            // Load debug report callback extension
            auto createFN = PFN_vkCreateDebugReportCallbackEXT(vkGetInstanceProcAddr(instance, "vkCreateDebugReportCallbackEXT"));
            if(createFN) {
                cout<<"EASYVK createFN SUCCESSFUL" << "\n";
                
                cout << "EASYVK createFN SUCCESSFUL" << "\n";
                createFN(instance, &debugCreateInfo, nullptr, &debugReportCallback);
            }
            else {
      //          LOGD("EASYVK createFN NOT SUCCESSFUL");
                cout << "EASYVK createFN NOT SUCCESSFUL" << "\n";
            }
        }

        // List out instance's enabled extensions
        uint32_t count;
        vkEnumerateInstanceExtensionProperties(nullptr, &count, nullptr);
        std::vector<VkExtensionProperties> extensions(count);
        vkEnumerateInstanceExtensionProperties(nullptr, &count, extensions.data());
        std::set<std::string> results;

        // Save the extension list to text file
        std::ofstream extensionFile("/data/data/com.example.litmustestandroid/files/extensions.txt");

        for (auto& extension : extensions) {
            extensionFile << extension.extensionName << "\n";
        }
        extensionFile.close();

        // Print out vulkan's instance version
        uint32_t version;
        PFN_vkEnumerateInstanceVersion my_EnumerateInstanceVersion = (PFN_vkEnumerateInstanceVersion)vkGetInstanceProcAddr(VK_NULL_HANDLE, "vkEnumerateInstanceVersion");
        if (nullptr != my_EnumerateInstanceVersion) {
            my_EnumerateInstanceVersion(&version);
        cout << "Vulkan Version: "<<VK_VERSION_MAJOR(version) << ", , " << VK_VERSION_MINOR(version) << " , " << VK_VERSION_PATCH(version) << "\n";
            
            cout << "Vulkan Version: " << VK_VERSION_MAJOR(version) << ","<<  VK_VERSION_MINOR(version) << " ," << VK_VERSION_PATCH(version) << "\n";
        }
        else {
        //    LOGD("Vulkan Version: vkEnumerateInstanceVersion not present");
            
            cout  << "Vulkan Version: vkEnumerateInstanceVersion not present" << "\n";
        }
    }

    std::vector<easyvk::Device> Instance::devices() {
        // Get physical device count
        uint32_t deviceCount = 0;
        vulkanCheck(vkEnumeratePhysicalDevices(instance, &deviceCount, nullptr));

        // Enumerate physical devices based on deviceCount
        std::vector<VkPhysicalDevice> physicalDevices(deviceCount);
        vulkanCheck(vkEnumeratePhysicalDevices(instance, &deviceCount, physicalDevices.data()));

        // Store devices in vector
        auto devices = std::vector<easyvk::Device>{};
        for (auto device : physicalDevices) {
            devices.push_back(easyvk::Device(*this, device));
        }
        return devices;
    }

    void Instance::teardown() {
        // Destroy debug report callback extension
        if (enableValidationLayers) {
            auto destroyFn = PFN_vkDestroyDebugReportCallbackEXT(vkGetInstanceProcAddr(instance,"vkDestroyDebugReportCallbackEXT"));
            if (destroyFn) {
                destroyFn(instance, debugReportCallback, nullptr);
            }
        }
        // Destroy instance
        vkDestroyInstance(instance, nullptr);
    }

    uint32_t getComputeFamilyId(VkPhysicalDevice physicalDevice) {
        // Get queue family count
        uint32_t queueFamilyPropertyCount = 0;
        vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, &queueFamilyPropertyCount, nullptr);

        std::vector<VkQueueFamilyProperties> familyProperties(queueFamilyPropertyCount);
        vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, &queueFamilyPropertyCount, familyProperties.data());

        uint32_t i = 0;
        uint32_t computeFamilyId = -1;

        // Get compute family id based on size of family properties
        for (auto queueFamily : familyProperties) {
            if (queueFamily.queueCount > 0 && (queueFamily.queueFlags & VK_QUEUE_COMPUTE_BIT)) {
                computeFamilyId = i;;
                break;
            }
            i++;
        }
        return computeFamilyId;
    }

    Device::Device(easyvk::Instance &_instance, VkPhysicalDevice _physicalDevice) :
        instance(_instance),
        physicalDevice(_physicalDevice),
        computeFamilyId(getComputeFamilyId(_physicalDevice)) {

            auto priority = float(1.0);
            auto queues = std::array<VkDeviceQueueCreateInfo, 1>{};

            // Define device queue info
            queues[0] = VkDeviceQueueCreateInfo {
                VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
                nullptr,
                VkDeviceQueueCreateFlags {},
                computeFamilyId,
                1,
                &priority
            };

            // Get device's enabled extensions
            uint32_t count;
            vkEnumerateDeviceExtensionProperties(physicalDevice, nullptr, &count, nullptr);
            std::vector<VkExtensionProperties> extensions(count);
            vkEnumerateDeviceExtensionProperties(physicalDevice, nullptr, &count, extensions.data());
            bool vulkan_memory_model_supported = false;

            for (auto& extension : extensions) {
                std::string name(extension.extensionName);
                if(name == "VK_KHR_vulkan_memory_model") {
           //         LOGD("Device supports vulkan memory model");
              cout << "Device supports vulkan memory model" << "\n";
                    vulkan_memory_model_supported = true;
                }
            }

            // Define device info
            VkDeviceCreateInfo deviceCreateInfo;
            if(vulkan_memory_model_supported) {
                deviceCreateInfo = {
                    VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
                    new VkPhysicalDeviceVulkanMemoryModelFeaturesKHR {
                        VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_MEMORY_MODEL_FEATURES_KHR,
                        nullptr,
                        true,
                        true,
                    },
                    VkDeviceCreateFlags {},
                    1,
                    queues.data()
                };
            }
            else {
                deviceCreateInfo = {
                    VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
                    nullptr,
                    VkDeviceCreateFlags{},
                    1,
                    queues.data()
                };
            }

            // Create device
            vulkanCheck(vkCreateDevice(physicalDevice, &deviceCreateInfo, nullptr, &device));

            // Define command pool info
            VkCommandPoolCreateInfo commandPoolCreateInfo {
                VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
                nullptr,
                VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT,
                computeFamilyId
            };

            // Create command pool
            vulkanCheck(vkCreateCommandPool(device, &commandPoolCreateInfo, nullptr, &computePool));

            // Define command buffer info
            VkCommandBufferAllocateInfo commandBufferAI {
                VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
                nullptr,
                computePool,
                VK_COMMAND_BUFFER_LEVEL_PRIMARY,
                1
            };

            // Allocate command buffers
            vulkanCheck(vkAllocateCommandBuffers(device, &commandBufferAI, &computeCommandBuffer));
        }

    // Retrieve device properties
    VkPhysicalDeviceProperties Device::properties() {
        VkPhysicalDeviceProperties physicalDeviceProperties;
        vkGetPhysicalDeviceProperties(physicalDevice, &physicalDeviceProperties);

        return physicalDeviceProperties;
    }

    uint32_t Device::selectMemory(VkBuffer buffer, VkMemoryPropertyFlags flags) {
        VkPhysicalDeviceMemoryProperties memProperties;
        vkGetPhysicalDeviceMemoryProperties(physicalDevice, &memProperties);

        VkMemoryRequirements memoryReqs;
        vkGetBufferMemoryRequirements(device, buffer, &memoryReqs);

        for(uint32_t i = 0; i < memProperties.memoryTypeCount; ++i){
            if( (memoryReqs.memoryTypeBits & (1u << i))
                && ((flags & memProperties.memoryTypes[i].propertyFlags) == flags))
            {
                return i;
            }
        }
        return uint32_t(-1);
    }

    // Get device queue
    VkQueue Device::computeQueue() {
        VkQueue queue;
        vkGetDeviceQueue(device, computeFamilyId, 0, &queue);
        return queue;
    }

    void Device::teardown() {
        vkDestroyCommandPool(device, computePool, nullptr);
        vkDestroyDevice(device, nullptr);
    }

    // Create new buffer
    VkBuffer getNewBuffer(easyvk::Device &_device, uint32_t size) {
        VkBuffer newBuffer;
        vulkanCheck(vkCreateBuffer(_device.device, new VkBufferCreateInfo {
            VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
            nullptr,
            VkBufferCreateFlags {},
            size * sizeof(uint32_t),
            VK_BUFFER_USAGE_STORAGE_BUFFER_BIT }, nullptr, &newBuffer));
        return newBuffer;
    }

    Buffer::Buffer(easyvk::Device &_device, uint32_t size) :
        device(_device),
        buffer(getNewBuffer(_device, size))
        {
            // Allocate and map memory to new buffer
            auto memId = _device.selectMemory(buffer, VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT);

            VkMemoryRequirements memReqs;
            vkGetBufferMemoryRequirements(device.device, buffer, &memReqs);

            vulkanCheck(vkAllocateMemory(_device.device, new VkMemoryAllocateInfo {
                VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
                nullptr,
                memReqs.size,
                memId}, nullptr, &memory));

            vulkanCheck(vkBindBufferMemory(_device.device, buffer, memory, 0));

            void* newData = new void*;
            vulkanCheck(vkMapMemory(_device.device, memory, 0, VK_WHOLE_SIZE, VkMemoryMapFlags {}, &newData));
            data = (uint32_t*)newData;
        }


    void Buffer::teardown() {
        vkUnmapMemory(device.device, memory);
        vkFreeMemory(device.device, memory, nullptr);
        vkDestroyBuffer(device.device, buffer, nullptr);
    }

    // Read spv shader files
    std::vector<uint32_t> read_spirv(const char* filename) {
        auto fin = std::ifstream(filename, std::ios::binary | std::ios::ate);
        if(!fin.is_open()){
            throw std::runtime_error(std::string("failed opening file ") + filename + " for reading");
        }
        const auto stream_size = unsigned(fin.tellg());
        fin.seekg(0);

        auto ret = std::vector<std::uint32_t>((stream_size + 3)/4, 0);
        std::copy( std::istreambuf_iterator<char>(fin), std::istreambuf_iterator<char>()
                   , reinterpret_cast<char*>(ret.data()));
        return ret;
    }

    VkShaderModule initShaderModule(easyvk::Device& device, const char* filepath) {
        std::vector<uint32_t> code = read_spirv(filepath);

        // Create shader module with spv code
        VkShaderModule shaderModule;
        vulkanCheck(vkCreateShaderModule(device.device, new VkShaderModuleCreateInfo {
            VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO,
            nullptr,
            0,
            code.size() * sizeof(uint32_t),
            code.data()
        }, nullptr, &shaderModule));
        return shaderModule;
    }

    VkDescriptorSetLayout createDescriptorSetLayout(easyvk::Device &device, uint32_t size) {
        std::vector<VkDescriptorSetLayoutBinding> layouts;
        // Create descriptor set with binding
        for (uint32_t i = 0; i < size; i++) {
            layouts.push_back(VkDescriptorSetLayoutBinding {
                i,
                VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                1,
                VK_SHADER_STAGE_COMPUTE_BIT
            });
        }
        // Define descriptor set layout info
        VkDescriptorSetLayoutCreateInfo createInfo {
            VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
            nullptr,
            VkDescriptorSetLayoutCreateFlags {},
            size,
            layouts.data()
        };
        VkDescriptorSetLayout descriptorSetLayout;
        vulkanCheck(vkCreateDescriptorSetLayout(device.device, &createInfo, nullptr, &descriptorSetLayout));
        return descriptorSetLayout;
    }

    // This function brings descriptorSet, buffers, and bufferInfo to create writeDescriptorSets,
    // which describes a descriptor set write operation
    void writeSets(
            VkDescriptorSet& descriptorSet,
            std::vector<easyvk::Buffer> &buffers,
            std::vector<VkWriteDescriptorSet>& writeDescriptorSets,
            std::vector<VkDescriptorBufferInfo>& bufferInfos) {

        // Define descriptor buffer info
        for (int i = 0; i < buffers.size(); i++) {
            bufferInfos.push_back(VkDescriptorBufferInfo{
                buffers[i].buffer,
                0,
                VK_WHOLE_SIZE
            });
        }

        // wow this bug sucked: https://medium.com/@arpytoth/the-dangerous-pointer-to-vector-a139cc42a192
        for (int i = 0; i < buffers.size(); i++) {
            writeDescriptorSets.push_back(VkWriteDescriptorSet {
                VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET,
                nullptr,
                descriptorSet,
                (uint32_t)i,
                0,
                1,
                VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                nullptr,
                &bufferInfos[i],
                nullptr
            });
        }
    }

    void Program::prepare() {
        VkSpecializationMapEntry specMap[1] = {VkSpecializationMapEntry{0, 0, sizeof(uint32_t)}};
        uint32_t specMapContent[1] = {workgroupSize};
        VkSpecializationInfo specInfo {1, specMap, sizeof(uint32_t), specMapContent};
        // Define shader stage create info
        VkPipelineShaderStageCreateInfo stageCI{
            VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
            nullptr,
            VkPipelineShaderStageCreateFlags {},
            VK_SHADER_STAGE_COMPUTE_BIT,
            shaderModule,
            "litmus_test",
            &specInfo};
        // Define compute pipeline create info
        VkComputePipelineCreateInfo pipelineCI{
            VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO,
            nullptr,
            {},
            stageCI,
            pipelineLayout
        };

        // Create compute pipelines
        vulkanCheck(vkCreateComputePipelines(device.device, {}, 1, &pipelineCI, nullptr,  &pipeline));

        // Start recording command buffer
        vulkanCheck(vkBeginCommandBuffer(device.computeCommandBuffer, new VkCommandBufferBeginInfo {VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO}));

        // Bind pipeline and descriptor sets
        vkCmdBindPipeline(device.computeCommandBuffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline);
        vkCmdBindDescriptorSets(device.computeCommandBuffer, VK_PIPELINE_BIND_POINT_COMPUTE,
                          pipelineLayout, 0, 1, &descriptorSet, 0, 0);

        // Bind push constants
        uint32_t pValues[3] = {0, 0, 0};
        vkCmdPushConstants(device.computeCommandBuffer, pipelineLayout, VK_SHADER_STAGE_COMPUTE_BIT, 0, easyvk::push_constant_size_bytes, &pValues);

        vkCmdPipelineBarrier(device.computeCommandBuffer, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, VK_PIPELINE_STAGE_HOST_BIT, 0,
                             1, new VkMemoryBarrier{VK_STRUCTURE_TYPE_MEMORY_BARRIER, nullptr, VK_ACCESS_SHADER_WRITE_BIT, VK_ACCESS_HOST_READ_BIT}, 0, {}, 0, {});

        // Dispatch compute work items
        vkCmdDispatch(device.computeCommandBuffer, numWorkgroups, 1, 1);

        //vkCmdPipelineBarrier(device.computeCommandBuffer, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, VK_PIPELINE_STAGE_HOST_BIT, 0,
                            //1, new VkMemoryBarrier{VK_STRUCTURE_TYPE_MEMORY_BARRIER, nullptr, VK_ACCESS_SHADER_WRITE_BIT, VK_ACCESS_HOST_READ_BIT}, 0, {}, 0, {});

        // End recording command buffer
        vulkanCheck(vkEndCommandBuffer(device.computeCommandBuffer));
    }

    void Program::run() {
        // Define submit info
        VkSubmitInfo submitInfo {
            VK_STRUCTURE_TYPE_SUBMIT_INFO,
            nullptr,
            0,
            nullptr,
            nullptr,
            1,
            &device.computeCommandBuffer,
            0,
            nullptr
        };

        auto queue = device.computeQueue();

        // Submit command buffer to queue, then wait until queue comes back to idle state
        vulkanCheck(vkQueueSubmit(queue, 1, &submitInfo, VK_NULL_HANDLE));
        vulkanCheck(vkQueueWaitIdle(queue));
    }

    void Program::setWorkgroups(uint32_t _numWorkgroups) {
        numWorkgroups = _numWorkgroups;
    }

    void Program::setWorkgroupSize(uint32_t _workgroupSize) {
        workgroupSize = _workgroupSize;
    }

    Program::Program(easyvk::Device &_device, const char* filepath, std::vector<easyvk::Buffer> &_buffers) :
        device(_device),
        shaderModule(initShaderModule(_device, filepath)),
        buffers(_buffers) {
            descriptorSetLayout = createDescriptorSetLayout(device, buffers.size());

            // Define pipeline layout info
            VkPipelineLayoutCreateInfo createInfo {
                VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
                nullptr,
                VkPipelineLayoutCreateFlags {},
                1,
                &descriptorSetLayout,
                1,
                new VkPushConstantRange {VK_SHADER_STAGE_COMPUTE_BIT, 0, easyvk::push_constant_size_bytes}
            };

            // Print out device's properties information
            if(!printDeviceInfo) {
                printDeviceInfo = true;
             //   LOGD("Device maxPushConstantsSize: %d", device.properties().limits.maxPushConstantsSize);
                
                printf("Device maxPushConstantsSize: %d", device.properties().limits.maxPushConstantsSize);
                
                printf("Device maxComputeWorkGroupSize: %d, %d, %d", device.properties().limits.maxComputeWorkGroupSize[0],
                                                                   device.properties().limits.maxComputeWorkGroupSize[1],
                                                                   device.properties().limits.maxComputeWorkGroupSize[2]);
                printf("Device maxComputeWorkGroupCount: %d, %d, %d", device.properties().limits.maxComputeWorkGroupCount[0],
                                                                    device.properties().limits.maxComputeWorkGroupCount[1],
                                                                    device.properties().limits.maxComputeWorkGroupCount[2]);
            }

            // Create a new pipeline layout object
            vulkanCheck(vkCreatePipelineLayout(device.device, &createInfo, nullptr, &pipelineLayout));

            // Define descriptor pool size
            VkDescriptorPoolSize poolSize {
                VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
                (uint32_t)buffers.size()
            };
            auto descriptorSizes = std::array<VkDescriptorPoolSize, 1>({poolSize});

            // Create a new descriptor pool object
            vulkanCheck(vkCreateDescriptorPool(device.device, new VkDescriptorPoolCreateInfo {
                VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO,
                nullptr,
                VkDescriptorPoolCreateFlags {},
                1,
                uint32_t(descriptorSizes.size()),
                descriptorSizes.data()}, nullptr, &descriptorPool));

            // Allocate descriptor set
            vulkanCheck(vkAllocateDescriptorSets(device.device, new VkDescriptorSetAllocateInfo {
                VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO,
                nullptr,
                descriptorPool,
                1,
                &descriptorSetLayout}, &descriptorSet));

            writeSets(descriptorSet, buffers, writeDescriptorSets, bufferInfos);

            // Update contents of descriptor set object
            vkUpdateDescriptorSets(device.device, writeDescriptorSets.size(), &writeDescriptorSets.front(), 0,{});
        }

    void Program::teardown() {
        vkDestroyShaderModule(device.device, shaderModule, nullptr);
        vkDestroyDescriptorPool(device.device, descriptorPool, nullptr);
        vkDestroyDescriptorSetLayout(device.device, descriptorSetLayout, nullptr);
        vkDestroyPipelineLayout(device.device, pipelineLayout, nullptr);
        vkDestroyPipeline(device.device, pipeline, nullptr);
    }
}



