"""
Speed Configuration for Tests
Adjust these values to control test execution speed
"""

class SpeedConfig:
    # Watchable mode - Slow for visual debugging
    WATCHABLE_MODE = {
        'after_action': 2.0,      # Wait after each action (tap, type)
        'after_page_load': 3.0,   # Wait after page loads
        'after_keyboard': 1.0,    # Wait after hiding keyboard
        'element_timeout': 30,    # Timeout to find elements
    }
    
    # Fast mode - Optimized for quick execution
    FAST_MODE = {
        'after_action': 0.2,      # Minimal wait after actions
        'after_page_load': 0.5,   # Quick page load check
        'after_keyboard': 0.15,   # Quick keyboard hide
        'element_timeout': 8,     # Shorter timeout
    }
    
    # Normal mode - Balanced speed and stability
    NORMAL_MODE = {
        'after_action': 0.5,      # Reasonable wait
        'after_page_load': 1.5,   # Moderate page load wait
        'after_keyboard': 0.5,    # Moderate keyboard wait
        'element_timeout': 15,    # Standard timeout
    }
    
    # Current mode - Change this to switch speeds
    CURRENT_MODE = FAST_MODE  # Options: WATCHABLE_MODE, NORMAL_MODE, FAST_MODE
    
    @classmethod
    def get_delay(cls, delay_type):
        """Get delay value for specific action type"""
        return cls.CURRENT_MODE.get(delay_type, 0.5)
    
    @classmethod
    def get_timeout(cls):
        """Get element timeout value"""
        return cls.CURRENT_MODE.get('element_timeout', 15)
    
    @classmethod
    def set_mode(cls, mode_name):
        """Set speed mode: 'watchable', 'normal', or 'fast'"""
        if mode_name == 'watchable':
            cls.CURRENT_MODE = cls.WATCHABLE_MODE
        elif mode_name == 'normal':
            cls.CURRENT_MODE = cls.NORMAL_MODE
        elif mode_name == 'fast':
            cls.CURRENT_MODE = cls.FAST_MODE
        else:
            raise ValueError(f"Invalid mode: {mode_name}. Use 'watchable', 'normal', or 'fast'")
