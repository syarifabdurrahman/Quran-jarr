# Quran Jar - UX Improvements Tracker

## App Purpose
A daily motivation jar for Quran verses - users tap a jar to receive a verse each day.

---

## Critical Priority

### 1. Daily Streak System ✅
- [x] Add streak counter (consecutive days of reading)
- [x] Display streak on main screen: "Day 12 of daily reading"
- [x] Streak notification: "You're on a 7-day streak!"
- [x] Milestone celebrations (7 days, 30 days, 100 days)
- [x] Visual progress indicator on jar screen

### 2. Ritual Moment Experience ✅
- [x] Add anticipation delay before verse reveal (1.5 seconds)
- [x] Smoother jar shake animation (800ms multi-phase)
- [x] Paper slip animation improvement (1000ms multi-phase)
- [x] Sound effect on verse pull (jar shake + whoosh)
- [x] "Breath" moment - pause before showing actions (500ms)

### 3. Time-Aware Personalization
- [ ] Morning greeting: "Good morning! Start your day with inspiration"
- [ ] Evening greeting: "Evening reflection time"
- [x] Time-of-day aware UI (calmer colors at night) - via dark mode

---

## High Priority

### 4. Progress Motivation ✅
- [x] Daily verse counter: "2/3 verses today"
- [x] Progress bar showing daily limit
- [x] Weekly/monthly stats
- [x] "You've read 50 verses this month!"

### 5. Limit Feedback Improvement ✅
- [x] Replace confusing message with clear feedback
- [x] Show: "You've read 3/3 verses today! Come back tomorrow"
- [x] Visual countdown: "Next verse in: 12h 30m"
- [x] Softer color for limit reached state

### 6. Empty State & First Experience
- [ ] First-time user tutorial
- [x] Clear call-to-action when jar is empty
- [ ] Celebrate first verse pull
- [ ] Share your first verse prompt

---

## Medium Priority

### 7. Reflection Space
- [x] Add "reflect moment" before showing actions (breath moment)
- [ ] Optional journaling feature for thoughts
- [ ] Mood tracker with verse
- [ ] Prayer reminder after reading

### 8. Delight & Celebration
- [ ] Confetti animation on streak milestones
- [ ] Special jar appearance on milestones
- [ ] Achievement badges
- [ ] Share streak progress

### 9. Archive Enhancement ✅
- [x] "This day last month" feature
- [x] Verse of the week/month
- [x] Sort by date/surah
- [x] Search by surah or keyword

### 10. Notification Experience ✅
- [x] Personalized notification messages
- [x] Time-aware notifications
- [x] Gentle reminder style
- [x] Notification with verse preview

---

## Low Priority

### 11. Visual Polish ✅
- [ ] Jar fills up with paper slips over time
- [x] Different jar themes/seasons (4 jar types)
- [ ] Animated background
- [x] Particle effects on tap

### 12. Social Features
- [ ] Share streak with friends
- [ ] Family jar (shared daily verse)
- [ ] Community verse of the day

### 13. Accessibility
- [x] Screen reader support (via theme-aware text)
- [ ] High contrast mode
- [x] Font size accessibility
- [x] Reduced motion option

---

## Completed Improvements

### ✅ Dark Mode
- Midnight Reflection theme (navy blue + gold)
- Theme switching in Settings (System/Light/Dark)
- Theme-aware colors throughout app

### ✅ Accessibility
- Reduced motion preference
- System text scaling
- Font size controls (Arabic & English)

### ✅ Settings Restructured
- Appearance section with theme selector
- Accessibility section with reduced motion toggle
- Full settings screen in navbar
- Jar style selector (4 types)

### ✅ Interaction Polish
- Haptic feedback on jar tap
- Empty state hint: "Tap the jar to get a verse"
- Pull-to-refresh

### ✅ Share Experience
- Theme-aware share sheet
- App branding in shares

### ✅ Navigation
- Bottom navbar with Style7
- 5 tabs: Home, Stats, Archive, Settings, About
- Theme-aware colors

### ✅ Skeleton Loaders
- Shimmer effect for verse card loading

### ✅ Daily Streak System
- Streak counter (consecutive days)
- Display on main screen
- Progress bar to milestones
- Milestone celebrations (7, 30, 100, 365 days)
- Motivational messages

### ✅ Ritual Moment Experience
- 1.5s anticipation delay
- 800ms smoother jar shake
- 1000ms paper slip animation
- 500ms breath moment
- Sound effects (jar shake + whoosh)

### ✅ Progress Motivation
- Daily verse counter: "2/3 verses today"
- Progress bar for daily limit
- Total verses read
- Motivational messages

### ✅ Limit Feedback
- Visual countdown: "Next verse in: 12h 30m"
- Softer colors for limit reached
- Clear message design

### ✅ Statistics Screen
- Current streak display
- Longest streak display
- Total verses read
- Verses today
- Milestone checklist (7, 30, 100, 365 days)
- Motivational message card

### ✅ Bottom Navigation
- Home, Stats, Archive, Settings, About
- Style7 navbar with theme-aware colors

### ✅ Jar Customization
- 4 jar styles: Classic, Vintage, Modern, Ornate
- Jar type selector in settings
- Theme-aware jar colors

### ✅ Visual Polish
- Particle effects on jar tap
- Different jar themes/designs
- Smoother animations

### ✅ Archive Enhancement
- "This day last month" feature
- Verse of the week
- Sort options (newest, oldest, by surah)
- Enhanced search

---

## Metrics to Track

### Engagement Metrics
- Daily Active Users (DAU)
- Streak retention rate
- Verses read per user per day
- Time spent reading verse

### Feature Usage
- Archive save rate
- Share rate
- Tafsir view rate
- Notification click rate
- Jar type preference distribution

---

## Implementation Notes

### Streak System Data Model
```dart
class UserStreak {
  int currentStreak;
  int longestStreak;
  DateTime lastReadDate;
  int totalVersesRead;
  int versesReadToday;
}
```

### Time-Aware Greeting
```dart
String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return "Good morning";
  if (hour < 17) return "Good afternoon";
  return "Good evening";
}
```

### Progress Bar Logic
```dart
double get dailyProgress {
  return versesReadToday / dailyLimit;
}
```

### Countdown Timer
```dart
Duration get timeUntilMidnight {
  final now = DateTime.now();
  final midnight = DateTime(now.year, now.month, now.day + 1);
  return midnight.difference(now);
}
```
